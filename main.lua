--[[============================================================================
main.lua
============================================================================]]--
class("RenoiseScriptingTool")(renoise.Document.DocumentNode)
function RenoiseScriptingTool:__init()
  renoise.Document.DocumentNode.__init(self)
  self:add_property("Name", "Untitled Tool")
  self:add_property("Id", "Unknown Id")
end

local manifest = RenoiseScriptingTool()
local ok, err = manifest:load_from("manifest.xml")
local tool_name = manifest:property("Name").value
local tool_id = manifest:property("Id").value

prefs = renoise.Document.create("ScriptingToolPreferences") {
 increment_amount = 1
}

renoise.tool().preferences = prefs

local increment_options = {
  1,
  2,
  3,
  4,
  5,
  10,
  20
}

function setIncrement(increment)
  print("Setting BPM Increment=" .. increment .. " previous=" .. prefs.increment_amount.value)
  prefs.increment_amount.value = increment
end

function bindSetIncrement(a)
   return function() return setIncrement(a) end
end

-- Add menu options for deciding BPM increment
for i,v in ipairs(increment_options) do
  renoise.tool():add_menu_entry({
    name = "Main Menu:Tools:" .. tool_name .. ":" .. "Set BPM Increment - " .. v,
    invoke = bindSetIncrement(v)
  })
end

--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------
function increment()
  renoise.song().transport.bpm = renoise.song().transport.bpm + prefs.increment_amount.value
end

function decrement()
 renoise.song().transport.bpm = renoise.song().transport.bpm - prefs.increment_amount.value
end

--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--Change and Display Tempo
renoise.tool():add_midi_mapping( {
  name = 'Global:Tools:Increment Tempo',
  invoke = function(message)
    if message:is_trigger() then
       increment()
    end
  end
})

renoise.tool():add_midi_mapping( {
  name = 'Global:Tools:Decrement Tempo',
  invoke = function(message)
    if message:is_trigger() then
       decrement()
    end
  end
})

