# PhunInfo

A welcome screen for your server, giving latest news, FAQ's and more.

# To configure

In addition to the standard installation processes (subscribe via Steam workshop, add to your config), you will need a server side file that holds your news. That is found in the ServerFiles/Lua folder of this repo. Feel free to customise to suit your server.

## Entry Properties

| Key     | Desc |
| ---      | ---       |
| title | string. Optional. The title. Optional |
| sticky     | boolean. Optional. if true, this message will appear before non sticky entries |
| value     | string. The text you want to display |
| backgroundImage     | optional string of a png within the texture folder |
