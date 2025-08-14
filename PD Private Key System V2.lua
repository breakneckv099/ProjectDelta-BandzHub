local KeyGuardLibrary =
loadstring(game:HttpGet('https://cdn.keyguardian.org/library/v1.0.0.lua'))()
local trueData = 'f507a18f0be64a8fa9abd3b0103d34e9'
local falseData = '0534c1b45ce4471eb10c32e0fc51f3ba'

KeyGuardLibrary.Set({
    publicToken = 'a9389132077740de915b96812d00be3c',
    privateToken = '641d5eef305f45cf9af2f91c53b36f85',
    trueData = trueData,
    falseData = falseData,
})

local getkey = KeyGuardLibrary.getLink()

local response = KeyGuardLibrary.validatePremiumKey(priv_key)

if response == trueData then
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/slotsuntiliwin/Project-Delta-Private-V2/refs/heads/main/Project%20Delta%20Private%20V2.lua'
        )
    )()
else
    game.StarterGui:SetCore('SendNotification', {
        Title = 'Key Failed!',
        Text = 'Please Check Key Then Try Again.',
        Time = 6,
    })
end
