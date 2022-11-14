do
    local scriptManager = getScriptManager()

    -- radio phone (for pager)
    local item = scriptManager:getItem('Base.CordlessPhone')
    if item then
        item:DoParam('DisplayCategory = Communications')
        item:DoParam('Type = Radio')
        item:DoParam('TwoWay = TRUE')
        item:DoParam('TransmitRange = 99999')
        item:DoParam('MicRange = 0')
        item:DoParam('BaseVolumeRange = 0')
        item:DoParam('IsPortable = TRUE')
        item:DoParam('IsTelevision = FALSE')
        item:DoParam('MinChannel = 200')
        item:DoParam('MaxChannel = 1000000')
        item:DoParam('UsesBattery = TRUE')
        item:DoParam('IsHighTier = TRUE')
        item:DoParam('UseDelta = 0.003')
    end

    -- put documents in wallet
    local items = {'Base.Wallet', 'Base.Wallet2', 'Base.Wallet3', 'Base.Wallet4'}
    for _,scriptName in ipairs(items) do
        local item = scriptManager:getItem(scriptName)
        if item then
            item:DoParam('Type = Container')
            item:DoParam('KeepOnDeath = TRUE')
            item:DoParam('AcceptItemFunction = AcceptItemFunction.DocumentationOnly')
            item:DoParam('Capacity = 50')
        end
    end

    -- no module lol?
    items = {'.CollegeDiploma', '.DrivingLicense', '.FirearmPermitA', '.FirearmPermitB', '.FirearmPermitC', '.HuntingPermit',
    '.IdentificationCard', '.MedicalLicense', '.PropertyDeed', '.Passport', '.VehicleRegistration'}
    for _,scriptName in ipairs(items) do
        local item = scriptManager:getItem(scriptName)
        if item then
            item:DoParam('KeepOnDeath = TRUE')
        end
    end
end