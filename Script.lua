local HttpGet = game.HttpGet 
local Market = game:GetService("MarketplaceService")
local Games = loadstring(HttpGet(game, "https://raw.githubusercontent.com/SansYT789/BlockMender/main/ListGame.lua"))()

local WindUI
do
    local ok, result = pcall(function()
        return loadstring(HttpGet(game, "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)

    if ok then
        WindUI = result
    else
        warn("Dialog load failed:", result)
    end
end

local function notify(title, content, icon)
    if WindUI and type(WindUI.Notify) == "function" then
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = 5,
            Icon = icon or "warning"
        })
    else
        warn(title .. ": " .. content)
    end
end

notify("Loading", "Script is loading, please wait.", "info")

local Tag = Games[game.PlaceId] or Games[game.GameId]
local Name = "Unknown"
pcall(function()
    local info = Market:GetProductInfo(game.PlaceId)
    if info and info.Name then
        Name = info.Name
    end
end)

if not Tag then
    notify("Unsupported Game", "This game is not supported yet.", "alert-triangle")
    return
end

local URL = "https://block-mender-api.vercel.app/api/load?id=" .. Tag

local code
local fetchOk, fetchErr = pcall(function()
    code = HttpGet(game, URL)

    if type(code) ~= "string" or code == "" then
        error("Empty response")
    end

    if code:sub(1, 2) == "--" then
        error(code)
    end
end)

if not fetchOk then
    warn("Loader fetch error:", fetchErr)
    notify("Error", tostring(fetchErr), "alert-triangle")
    return
end

local fn, loadErr = loadstring(code)
if not fn then
    warn("Loader compile error:", loadErr)
    notify("Error", tostring(loadErr), "alert-triangle")
    return
end

notify("Supported Game", string.format("Support script for %s!", Name), "play")

local runner = task.spawn or spawn
runner(function()
    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("Script runtime error:", runErr)
        notify("Error", tostring(runErr), "alert-triangle")
    end
end)