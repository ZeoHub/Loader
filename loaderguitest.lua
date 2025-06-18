if not game:IsLoaded() then game.Loaded:Wait() end

-- Queue this GUI script to run on every teleport/serverhop
local guiSource = "https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinderlua" -- CHANGE to your raw GitHub or Pastebin link
local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end
queueTeleport(('loadstring(game:HttpGet("%s"))()'):format(guiSource))

-- Remove duplicate GUI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("PersistentOldServerFinderGui")
if oldGui then oldGui:Destroy() end

-- Create visible GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PersistentOldServerFinderGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
mainFrame.Size = UDim2.new(0, 300, 0, 160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0

local uicorner = Instance.new("UICorner", mainFrame)
uicorner.CornerRadius = UDim.new(0, 16)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Old Server Finder"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
titleLabel.TextSize = 26

local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Position = UDim2.new(0, 0, 0, 40)
infoLabel.Size = UDim2.new(1, 0, 0, 50)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "This GUI will always show after rejoin/serverhop!"
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextSize = 16
infoLabel.TextWrapped = true

local button = Instance.new("TextButton", mainFrame)
button.Position = UDim2.new(0.5, -90, 0.7, 0)
button.Size = UDim2.new(0, 180, 0, 38)
button.Text = "Run Menace Hub"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(235, 235, 235)
button.Font = Enum.Font.GothamSemibold
button.TextSize = 20
button.AutoButtonColor = true

local buttonCorner = Instance.new("UICorner", button)
buttonCorner.CornerRadius = UDim.new(0, 12)

button.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinderv1", true))()
    end)
end)

mainFrame.Active = true
mainFrame.Draggable = true

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 82, 82)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.ZIndex = 3
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- === Your Script's Core Logic Below (unchanged) ===

local o = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/Gui.lua"))()
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

local oldVersionMax = 1279
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

-- Always load OldServerFinder GUI (after logic)
task.wait(1)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Load/refs/heads/main/OldServerFinder"))()
end)
