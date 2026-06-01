-- Install Hammerspoon and this config from Terminal:
--
--   brew install --cask hammerspoon
--   mkdir -p "$HOME/.hammerspoon/Spoons"
--   spoon="$HOME/.hammerspoon/Spoons/MiddleClickDragScroll.spoon"
--   if test -d "$spoon/.git"; then
--     git -C "$spoon" pull --ff-only
--   else
--     git clone https://github.com/benediktwerner/MiddleClickDragScroll.spoon.git "$spoon"
--   fi
--   curl -fsSL https://raw.githubusercontent.com/alxli/dotfiles/master/.hammerspoon/init.lua \
--     -o "$HOME/.hammerspoon/init.lua"
--   open -a Hammerspoon
--
-- Grant Hammerspoon Accessibility access when macOS prompts for it. This
-- enables Windows-like middle-click drag scrolling system-wide.
-- Draw a compact four-direction scroll marker instead of the spoon's plain circle.
local function makeScrollIndicator()
  local light = { white = 1, alpha = 0.85 }
  local function point(x, y)
    return { x = x .. "%", y = y .. "%" }
  end
  local function triangle(x1, y1, x2, y2, x3, y3)
    return {
      type = "segments", action = "fill", closed = true, fillColor = light,
      coordinates = { point(x1, y1), point(x2, y2), point(x3, y3) },
    }
  end

  return hs.canvas.new({ w = 36, h = 36 }):appendElements(
    {
      type = "circle",
      action = "fill",
      radius = "47%",
      fillColor = { red = 0, green = 0, blue = 0, alpha = 0.55 },
    },
    {
      type = "circle",
      action = "fill",
      radius = "7%",
      fillColor = light,
    },
    triangle(50, 14, 41, 28, 59, 28),
    triangle(50, 86, 41, 72, 59, 72),
    triangle(14, 50, 28, 41, 28, 59),
    triangle(86, 50, 72, 41, 72, 59)
  )
end

local MiddleClickDragScroll = hs.loadSpoon("MiddleClickDragScroll")
  :configure({ canvas = makeScrollIndicator() })
  :start()
