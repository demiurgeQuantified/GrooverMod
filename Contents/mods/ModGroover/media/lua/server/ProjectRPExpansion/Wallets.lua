local documentation = {['.CollegeDiploma'] = true, ['.DrivingLicense'] = true, ['.FirearmPermitA'] = true, ['.FirearmPermitB'] = true,
['.FirearmPermitC'] = true, ['.HuntingPermit'] = true, ['.IdentificationCard'] = true, ['.MedicalLicense'] = true, ['.PropertyDeed'] = true,
['.Passport'] = true, ['.VehicleRegistration'] = true}

function AcceptItemFunction.DocumentationOnly(container, item)
    return documentation[item:getFullType()]
end