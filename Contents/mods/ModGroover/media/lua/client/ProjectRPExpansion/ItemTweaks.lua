do
    local scriptManager = getScriptManager()

    local cordlessPhone = scriptManager:getItem('Base.CordlessPhone')
    cordlessPhone:DoParam('DisplayCategory = Communications')
    cordlessPhone:DoParam('Type = Radio')
    cordlessPhone:DoParam('TwoWay = TRUE')
    cordlessPhone:DoParam('TransmitRange = 99999')
    cordlessPhone:DoParam('MicRange = 0')
    cordlessPhone:DoParam('BaseVolumeRange = 0')
    cordlessPhone:DoParam('IsPortable = TRUE')
    cordlessPhone:DoParam('IsTelevision = FALSE')
    cordlessPhone:DoParam('MinChannel = 200')
    cordlessPhone:DoParam('MaxChannel = 1000000')
    cordlessPhone:DoParam('UsesBattery = TRUE')
    cordlessPhone:DoParam('IsHighTier = TRUE')
    cordlessPhone:DoParam('UseDelta = 0.003')
end