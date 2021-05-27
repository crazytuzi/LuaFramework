LuckyDrawData = LuckyDrawData or BaseClass()

function LuckyDrawData:__init()
    if LuckyDrawData.Instance ~= nil then
        ErrorLog("[WingShenyuData] Attemp to create a singleton twice !")
    end
    LuckyDrawData.Instance = self
end

function LuckyDrawData:__delete()
    LuckyDrawData.Instance = nil
end