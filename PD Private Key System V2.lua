local KeyGuardLibrary =
    loadstring(game:HttpGet('https://cdn.keyguardian.org/library/v1.0.0.lua'))()
local trueData = '8497af9d4b25486596b5cf86a5752b76'
local falseData = '8a61aea15feb4604b4f01069e4572e03'

KeyGuardLibrary.Set({
    publicToken = 'a9389132077740de915b96812d00be3c',
    privateToken = '641d5eef305f45cf9af2f91c53b36f85',
    trueData = trueData,
    falseData = falseData,
})

local Fluent = loadstring(
    game:HttpGet(
        'https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'
    )
)()
local key = ''

local Window = Fluent:CreateWindow({
    Title = 'Project Delta Private Script - Key System',
    SubTitle = 'by - breakneckv09',
    TabWidth = 160,
    Size = UDim2.fromOffset(490, 270),
    Acrylic = false,
    Theme = 'Dark',
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
    KeySys = Window:AddTab({
        Title = 'Project Delta Private | V2',
        Icon = 'key',
    }),
}

local Entkey = Tabs.KeySys:AddInput('Input', {
    Title = 'Enter Key',
    Description = '',
    Default = '',
    Placeholder = 'Enter key…',
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        key = Value
    end,
})

local Checkkey = Tabs.KeySys:AddButton({
    Title = 'Check Key',
    Description = '',
    Callback = function()
        local response = KeyGuardLibrary.validatePremiumKey(key)
        if response == trueData then
            print("Working")
        else
            print("Not Working")
        end
    end,
})

local Getkey = Tabs.KeySys:AddButton({
    Title = 'Copy Store Link',
    Description = '',
    Callback = function()
        setclipboard("https://bandzhubsupply.mysellauth.com")
    end,
})

Window:SelectTab(1)
