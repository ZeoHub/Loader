if not game:IsLoaded() then game.Loaded:Wait() end

local function prompt(title, text)
    -- ... [prompt function as you wrote it] ...
    -- (omitted for brevity, unchanged)
end

local o = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinder"))()
function nt(n, c)
    if o and o.MakeNotification then
        o:MakeNotification({
            Name = n,
            Content = c,
            Image = "rbxassetid://4483345998",
            Time = 6
        })
    else
        warn("[Notification]", n, c)
    end
end

_G.patched = _G.patched or false
if _G.patched then
    nt("PATCHED","Dupe Sheckles has been patched and it won't work now.")
    nt("NOTICE","We'll come back soon once a new bug or script has been found!")
    return
end

local gagid = 126884695634066
if game.PlaceId ~= gagid then
    nt("Wrong Game", "This script is for Grow a Garden only!")
    return
end

local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end
local oldVersionMax = 1279 -- servers with this place version or lower are considered old
local currentVersion = game.PlaceVersion

local shf = ([[
    if not _G.exeonce then
        _G.exeonce = true
        repeat task.wait() until game:IsLoaded()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinderv1", true))()
    end
]]):format(oldVersionMax)
queueTeleport(shf)

local function checkBloodMoon()
    local shrine = workspace:FindFirstChild("Interaction") and workspace.Interaction:FindFirstChild("UpdateItems") and workspace.Interaction.UpdateItems:FindFirstChild("BloodMoonShrine")
    if shrine and shrine:IsA("Model") then
        local part = shrine.PrimaryPart or shrine:FindFirstChildWhichIsA("BasePart")
        if part then
            return (part.Position - Vector3.new(-83.157, 0.3, -11.295)).Magnitude < 0.1
        end
    end
    return false
end

local lastHopAttempt = 0
local function sh()
    if os.time() - lastHopAttempt < 5 then
        nt("Please Wait", "Server hop cooldown...")
        return false
    end
    lastHopAttempt = os.time()

    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if typeof(req) ~= "function" then 
        nt("Error", "No HTTP request function available")
        return false
    end
    task.wait(math.random(1, 3))

    local hs = game:GetService("HttpService")
    local tp = game:GetService("TeleportService")
    local res = req({
        Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
        Method = "GET"
    })

    if not res then
        nt("Error", "HTTP request failed")
        return false
    end

    if res.StatusCode == 429 then
        nt("Rate Limited", "Please wait a few minutes before trying again")
        return false
    elseif res.StatusCode ~= 200 then 
        nt("Error", "Server request failed (Code: "..res.StatusCode..")")
        return false 
    end

    local success, data = pcall(function() return hs:JSONDecode(res.Body) end)
    if not success or not data or not data.data then 
        nt("Error", "Failed to read server data")
        return false
    end

    local list = {}
    for _, v in ipairs(data.data) do
        if type(v) == "table" and v.id ~= game.JobId then
            local playing = tonumber(v.playing) or 0
            local max = tonumber(v.maxPlayers) or 100
            local placeVersion = tonumber(v.placeVersion) or 0
            if playing < max and placeVersion <= oldVersionMax then
                table.insert(list, v.id)
            end
        end
    end

    if #list > 0 then
        nt("Server Hop", "Found "..#list.." servers with version ≤ "..oldVersionMax)
        task.wait(1)
        nt("Teleporting", "Joining server with old version...")
        task.wait(0.5)
        tp:TeleportToPlaceInstance(game.PlaceId, list[math.random(#list)])
        return true
    else
        nt("No Servers", "No available servers with version ≤ "..oldVersionMax.." found")
        return false
    end
end

if currentVersion <= oldVersionMax then
    nt("Perfect Server!", "This server supports the Infinite Sheckles Script!")
else
    nt("New Server Detected!", "Version: " .. currentVersion)
    task.wait(0.5)
    nt("Searching...", "Looking for a server with version ≤ "..oldVersionMax.."...")
    local success = sh()
    if not success then
        task.wait(5)
        sh()
    end
end

-- >>>> Add this at the end <<<<
task.wait(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinder"))()
