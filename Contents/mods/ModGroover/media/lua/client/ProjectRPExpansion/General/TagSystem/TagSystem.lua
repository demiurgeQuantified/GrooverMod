require 'ProjectRP/General/TagSystem/TagSystem'

---@param username string|IsoPlayer
---@param tag string
function ProjectRP.Client.TagSystem.HaveProfessionTag(username, tag)
    local userDatabase = ModData.getOrCreate("UserDatabase")
    if instanceOf(username, 'IsoPlayer') then
        username = username:getUsername()
    end
    if userDatabase[username] == nil then return end
    return userDatabase[username].professionTags[tag]
end