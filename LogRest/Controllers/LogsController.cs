using log_rest;
using Microsoft.AspNetCore.Mvc;
namespace log_rest.Controllers;

[Route("api/[controller]")]
[ApiController]
public class LogsController : ControllerBase
{
    private readonly string _directoryLocation;
    private readonly string _fileNameTemplate = "PAM-*.log"; // configurable filename template
    private readonly IConfiguration _configuration;
    private readonly ILogger _logger;

    public LogsController(ILogger<LogsController> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
        _directoryLocation = _configuration["LogDirectory"];
        _fileNameTemplate = _configuration["LogFileNameTemplate"] ?? _fileNameTemplate;
    }

    [HttpGet]
    public ActionResult<IEnumerable<Log>> GetAll([FromQuery] List<string> name = null)
    {
        // Get all files in the directory that match the filename template
        var files = new DirectoryInfo(_directoryLocation)
            .GetFiles(_fileNameTemplate)
            .Select(f => new Log
            {
                Id = f.Name,
                Name = f.Name,
                CreatedTimeUtc = f.CreationTime.ToUniversalTime(),
                LastModifiedTimeUtc = f.LastWriteTime.ToUniversalTime(),
                SizeInBytes = f.Length
            })
            .Where(f => name == null || name.Contains(f.Name) || name.Any(n => f.Name.Contains(n)));

        return Ok(files);
    }

    [HttpGet("{id}")]
    public ActionResult<List<LogMessage>> Get(string id)
    {
        var file = new FileInfo(Path.Combine(_directoryLocation, id));
        if (!file.Exists)
        {
            return NotFound();
        }

        // Loop the lines of the file and parse each line
        // into a LogMessage object
        var logEntries = new List<LogMessage>();
        int lineNumber = 1;
        using (var reader = file.OpenText())
        {
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                var logEntry = new LogMessage(id, lineNumber++, line);
                logEntries.Add(logEntry);
            }
        }
        return Ok(logEntries);
    }

    [HttpGet("Search")]
    // Search for log messages that match the specified criteria
    public async Task<ActionResult<List<LogMessage>>> SearchAsync([FromQuery] List<string> filterText = null, [FromQuery] LogLevel? level = null, 
                                            [FromQuery] DateTime? startDate = null, [FromQuery] DateTime? endDate = null,
                                            [FromQuery] List<string> logId = null,
                                            CancellationToken token = default)
    {
        // Log the query parameters
        _logger.LogInformation("Searching for log messages with the following parameters: filterText={filterText}, level={level}, startDate={startDate}, endDate={endDate}, logId={logId}", filterText, level, startDate, endDate, logId);
        // Get all files in the directory that match the filename template
        var logEntries = new List<LogMessage>();
        var files = new DirectoryInfo(_directoryLocation)
            .GetFiles(_fileNameTemplate)
            .Where(f => logId == null || logId.Count() == 0 || logId.Contains(f.Name))
            .ToList();

        _logger.LogInformation("Found {fileCount} files", files.Count);
        foreach (var file in files)
        {
            int lineNumber = 0;
            LogMessage logEntry = null;
            using (var reader = file.OpenText())
            {
                string line;
                
                while ((line = await reader.ReadLineAsync(token)) != null)
                {
                    lineNumber++;
                    try {
                        var nextEntry = new LogMessage(file.Name, lineNumber, line);
                        if (logEntry != null) {
                            if (LogEntryIsMatch(logEntry, filterText, level, startDate, endDate)) {
                                logEntries.Add(logEntry);
                            }
                        }
                        logEntry = nextEntry;                        
                    }
                    catch (Exception ex)
                    {
                        if (logEntry != null) {
                            logEntry.Message += line;
                        
                            _logger.LogDebug("Error parsing log line: {line}", line);
                        }
                    }
                }
            }
            if (logEntry != null && LogEntryIsMatch(logEntry, filterText, level, startDate, endDate)) {
                logEntries.Add(logEntry);
            }
        }
        _logger.LogInformation("Found {logEntryCount} log entries", logEntries.Count);
        return Ok(logEntries.OrderBy(l => l.Date).ThenBy(l => l.LineNumber));
    }

    private bool LogEntryIsMatch(LogMessage logEntry, List<string> filterText, LogLevel? level, DateTime? startDate, DateTime? endDate)
    {
        return (level == null || logEntry.Level >= level) &&
               (startDate == null || logEntry.Date >= startDate) &&
               (endDate == null || logEntry.Date <= endDate || startDate == endDate && (logEntry.Date - endDate.Value).TotalMilliseconds < 999) &&
               (filterText == null || filterText.Count == 0 || SearchForText(logEntry, filterText));
    }

    // Search for text in the log message
    private bool SearchForText(LogMessage logEntry, List<string> filterText)
    {
        int found = 0;
        foreach (var text in filterText)
        {
            if (logEntry.Message.Contains(text, StringComparison.OrdinalIgnoreCase))
            {
                found++;
            }
        }
        return found == filterText.Count;
    }
}
