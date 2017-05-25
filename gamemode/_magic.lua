local triggerID = 2914
local t1 = ents.GetMapCreatedEntity(triggerID)
print(t1)
t1:Fire('Disable')

-- -- print(Entity(1024):MapCreationID())

-- PrintTable(t1:GetKeyValues())
-- print"-----"
-- PrintTable(t1:GetSaveTable())
-- -- PrintTable({ a = 9})

-- hook.Add("EntityKeyValue", "beans", function(ent, key, value)
--     local cl = ent:GetClass()
--     if cl ~= "trigger_once" and cl ~= "env_explosion" then return end
--     print(ent, key, value)
--     ent.kvs = ent.kvs or {}
--     table.insert(ent.kvs, { key, value })
--     -- ent.kvs[key] = value
-- end)

-- PrintTable(t1.kvs)

local t2 = ents.Create('trigger_multiple')
for _, kv in ipairs(t1.kvs) do
    if kv[1] == "classname" then continue end
    t2:SetKeyValue(kv[1], kv[2])
end
t2:SetKeyValue("wait", 0)
t2:Spawn()
t2:Activate()
print(t2)


-- local observerpos = Vector(-838.205627, -1734.419067, 94.358025)
-- concommand.Add("meow", function(ply) ply:SetPos(observerpos) end)

-- local a = Entity(1496)
-- print(a:MapCreationID())
-- a:Fire'disable'
-- me:SetPos(a:GetPos())

for _, ent in pairs(ents.FindInSphere(me:GetPos(), 100)) do
    if ent:GetClass() == "env_explosion" then
        print(ent:GetName())
        -- PrintTable(ent:GetKeyValues())
        -- ent:SetKeyValue("spawnflags", 2)
    end
end
