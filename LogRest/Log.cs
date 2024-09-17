namespace log_rest;
public class Log
{
    public string Id { get; set; }
    public string Name { get; set; }
    public DateTime CreatedTimeUtc { get; set; }
    public DateTime LastModifiedTimeUtc { get; set; }
    public long SizeInBytes { get; set; }
}
