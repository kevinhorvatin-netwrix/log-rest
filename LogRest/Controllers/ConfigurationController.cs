using log_rest;
using Microsoft.AspNetCore.Mvc;
namespace log_rest.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ConfigurationController : ControllerBase
{
    private readonly IConfiguration _configuration;
    public ConfigurationController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public ActionResult<IEnumerable<object>> GetAll()
    {
        var configurations = _configuration.AsEnumerable()
            .Select(c => new
            {
                Key = c.Key,
                Value = c.Value
            });

        return Ok(configurations);
    }
}
