
local tbItem = Item:GetClass("RecordStone");

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "使用"};
    tbUseSetting.fnFirst = function ()
   		local tbStoneList = RecordStone:GetCurStoneList(me)     
        for i,nStoneId in ipairs(tbStoneList) do
            if nStoneId == nTemplateId then
                me.CenterMsg("已有同样的铭刻石")
                return
            end
        end

   		if #tbStoneList < RecordStone.MAX_RECORD_STONE_NUM then
   			RecordStone:DoRequestRecord(nTemplateId, #tbStoneList  +1)
   		else
   			Ui:OpenWindow("InscriptionChangePanel", nTemplateId) 
   		end
   		Ui:CloseWindow("ItemTips")
    end;

    return tbUseSetting;        
end