--[[
	Slide - gamemode/mapfixes/triggers.lua

    Copyright 2017 Lex Robinson

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--]]
DEFINE_BASECLASS "gamemode_base"

local function replaceTrigger(ent)
    if not ent.kvs then
        ErrorNoHalt(string.format("Entity %s doesn't have its .kvs?", ent))
        return
    end

    -- Take the ent out of the game but don't remove it (Just in case [?])
    ent:Fire("Disable")

    local replacement = ents.Create('trigger_multiple')
    for _, kv in ipairs(ent.kvs) do
        if kv[1] ~= "classname" then
            replacement:SetKeyValue(kv[1], kv[2])
        end
    end
    replacement:SetKeyValue("wait", 0)
    replacement:Spawn()
    replacement:Activate()
end

function GM:ReplaceTriggerOnces()
    for _, ent in pairs(ents.FindByClass("trigger_once")) do
        replaceTrigger(ent)
    end
end
