function love.conf(t)
    -- Read viewport dimensions written by the JS preRun hook in index.html.
    -- Falls back to a sensible phone-portrait size if not running in the browser.
    local f = io.open('/viewport', 'r')
    if f then
        local w, h = f:read():match('(%d+) (%d+)')
        f:close()
        t.window.width  = tonumber(w) or 750
        t.window.height = tonumber(h) or 1334
    else
        t.window.width  = 750
        t.window.height = 1334
    end
    t.window.title = "Cow Game"
    t.window.borderless = true
end
