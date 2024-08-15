TweakManager = {}

local broken_chance = 0.6;
local broken_override_chance = 0.5;

-- LOCAL FUNCTIONS --

local function set_broken_chance()
  TweakDB:SetFlat("LootInjection.DefaultLootInjectionSettings.brokenChance", broken_chance)
end

local function set_broken_override_chance()
  TweakDB:SetFlat("LootInjection.DefaultLootInjectionSettings.brokenOverrideChance", broken_override_chance)
end

-- TWEAKMANAGER FUNCTIONS --

---@param settings table
-- Updates TweakDB for settings changed
function TweakManager:apply_settings(settings)

  -- broken_chance
  if broken_chance ~= settings.brokenChance then
    broken_chance = settings.brokenChance
    set_broken_chance()
  end

  -- broken_override_chance
  if broken_override_chance ~= settings.brokenOverrideChance then
    broken_override_chance = settings.brokenOverrideChance
    set_broken_override_chance()
  end
end

return TweakManager