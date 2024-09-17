using System.Globalization;
using System.Text.RegularExpressions;
using System;

namespace log_rest;
public class LogMessage
{
    // Log message format:
    // 2023-01-06 14:26:19.656 -05:00 [DBG] ["9ee004c5-ae43-4cb9-914c-f3410131236a"] - Get-SbPAMAzureAdHostScanUsers: Skipping on-premises user kchance@avitahs.org
    // Regex for parsing log message:
    // ^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3} -\d\d:\d\d) \[(\S+)\] - (.+)$
    private void ParseLine(string line)
    {
        Regex regex = new Regex(@"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3} [-+]\d\d:\d\d) \[(\S{3})\] (.*)$");
        Match match = regex.Match(line);
        if (match.Success)
        {
            if (!DateTime.TryParseExact(match.Groups[1].Value, "yyyy-MM-dd HH:mm:ss.fff zzz", 
                    CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal,
                    out DateTime date))
            {
                throw new Exception($"Unable to parse date in line: {line}");
            }
            Date = date.ToUniversalTime();
            Level = ConvertLogLevel(match.Groups[2].Value);
            Message = match.Groups[3].Value;
        }
        else
        {
            throw new Exception($"Unable to parse line: {line}");
        }
    }

    private LogLevel ConvertLogLevel(string level)
    {
        return level switch
        {
            "DBG" => LogLevel.Debug,
            "INF" => LogLevel.Information,
            "WRN" => LogLevel.Warning,
            "ERR" => LogLevel.Error,
            "FTL" => LogLevel.Critical,
            _ => LogLevel.Information
        };
    }
    public LogMessage()
    {
    }
    public LogMessage(string logId, int lineNumber, string line)
    {
        LogId = logId;
        LineNumber = lineNumber;
        ParseLine(line);
    }

    public int LineNumber { get; set; }
    public string LogId { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public LogLevel Level { get; set; }
    public string Message { get; set; } = string.Empty;
}