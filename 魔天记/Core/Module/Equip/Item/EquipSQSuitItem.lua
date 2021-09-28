require "Core.Module.Common.UIItem"


local EquipSQSuitItem = UIItem:New();
local greenCode = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]"
local grayCode = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_greyf()) .. "]"

function EquipSQSuitItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtJindu = UIUtil.GetChildByName(self.transform, "UILabel", "jindu")
    self._txtAttrList = UIUtil.GetChildByName(self.transform, "UILabel", "list")

    self:UpdateItem(self.data)
end

function EquipSQSuitItem:_Dispose()

end

function EquipSQSuitItem:UpdateItem(data, hasGet)
    self.data = data;

    if (self.data) then

        self._txtName.text = LanguageMgr.Get("EquipSQSuitItem/label1", { a = self.data.piece, b = self.data.star });

        if hasGet then
            self._txtJindu.text = "(" .. self.data.piece .. "/" .. self.data.piece .. ")"
        else
            self._txtJindu.text = "(" .. MouldingDataManager.GetEqNumByStar(self.data.star) .. "/" .. self.data.piece .. ")"
        end


        local attr = ProductInfo.GetSampleBaseAtt(data);

        local list = ""
        local count = table.getCount(attr)
        if (not hasGet) then
            list = list .. grayCode
        end

        for i = 1, count do
            if (hasGet) then
                list = list .. attr[i].des .. ": " .. greenCode .. "+" .. attr[i].property .. attr[i].sign .. "[-]"
            else
                list = list .. attr[i].des .. ": +" .. attr[i].property .. attr[i].sign
            end

            if (i ~= count) then
                list = list .. "\n"
            end
        end

        if (not hasGet) then
            list = list .. "[-]"
        end

        self._txtAttrList.text = list

    end
end

return EquipSQSuitItem 