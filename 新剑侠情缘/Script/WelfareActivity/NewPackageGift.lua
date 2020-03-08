function NewPackageGift:OnSyncState(tbAward, nVersion, nCloseTime, bCanGain)
    self.tbAward = tbAward or self.tbAward
    self.nVersion = nVersion
    self.nCloseTime = nCloseTime
    self.bCanGain = bCanGain
    NewInformation:PushLocalInformation()
end

function NewPackageGift:GetVersion()
    return self.nVersion
end

function NewPackageGift:GetCloseTime()
    return self.nCloseTime
end

function NewPackageGift:CheckCanGain()
    return self.bCanGain
end