using log_rest;
using Microsoft.Extensions.Logging;

namespace LogRestTest;

[TestClass]
public class LogMessageTest
{
    [TestMethod]
    public void TestDateParse()
    {
        var line = "2022-09-22 16:45:21.919 +02:00 [INF] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual(new DateTime(2022, 9, 22, 14, 45, 21, 919, DateTimeKind.Utc), logMessage.Date);
        Assert.AreEqual(LogLevel.Information, logMessage.Level);
    }

    [TestMethod]
    public void TestLogIdParse()
    {
        var line = "2022-09-22 16:45:21.919 +02:00 [INF] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual("PAM-2022-09-22.log", logMessage.LogId);
    }

    [TestMethod]
    public void TestLogLevelParse()
    {
        var line = "2022-09-22 16:45:21.919 +02:00 [DBG] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual(LogLevel.Debug, logMessage.Level);
    }

    [TestMethod]
    public void TestCriticalLogLevelParse()
    {
        var line = "2022-09-22 16:45:21.919 +02:00 [FTL] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual(LogLevel.Critical, logMessage.Level);
    }

    [TestMethod]
    public void TestWarningLogLevelParse()
    {
        var line = "2022-09-22 16:45:21.919 +02:00 [WRN] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual(LogLevel.Warning, logMessage.Level);
    }

    [TestMethod]
    public void TestNegativeTimeOffset()
    {
        var line = "2022-09-22 16:45:21.919 -02:00 [WRN] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1, line);
        Assert.AreEqual(new DateTime(2022, 9, 22, 18, 45, 21, 919, DateTimeKind.Utc), logMessage.Date);
    }

    [TestMethod]
    public void TestBadMessageParseThrows()
    {
        var line = "2022-13-22 16:45:21.919 -02:00 [WRN] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        Assert.ThrowsException<Exception>(() => new LogMessage("PAM-2022-09-22.log", 1, line));
    }

    [TestMethod]
    public void TestLineNumberAssigned()
    {
        var line = "2022-12-22 16:45:21.919 -02:00 [WRN] Connected to hub {\"pid\": 5916, \"hub\": \"middlewarehub\"}";
        var logMessage = new LogMessage("PAM-2022-09-22.log", 1234, line);
        Assert.AreEqual(1234, logMessage.LineNumber);
    }
}