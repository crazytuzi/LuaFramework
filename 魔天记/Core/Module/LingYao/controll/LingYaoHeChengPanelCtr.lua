require "Core.Module.LingYao.View.item.LingYaoSetItem"

require "Core.Module.LingYao.controll.LingYaoHeChengLeftPanelCtr"
require "Core.Module.LingYao.controll.LingYaoHeChengRightPanelCtr"

LingYaoHeChengPanelCtr = class("LingYaoHeChengPanelCtr");

function LingYaoHeChengPanelCtr:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeChengPanelCtr });
    return self
end

function LingYaoHeChengPanelCtr:Init(gameObject, i)

    self.gameObject = gameObject;
    self.i = i;


    self.panel_left = UIUtil.GetChildByName(self.gameObject, "Transform", "panel_left");
   

    self.leftPCtr = LingYaoHeChengLeftPanelCtr:New();
    self.leftPCtr:Init(self.panel_left, i)


end

LingYaoHeChengPanelCtr.MESSAGE_LINGYAOHECHENGPANELCTR_NPOINT_CHANGE = "MESSAGE_LINGYAOHECHENGPANELCTR_NPOINT_CHANGE";

function LingYaoHeChengPanelCtr:UpInfos(setTip)

    if self.leftPCtr ~= nil then
       local b =  self.leftPCtr:UpInfos(setTip);
      
       
       if self.i==1 then
          MessageManager.Dispatch(LingYaoHeChengPanelCtr,LingYaoHeChengPanelCtr.MESSAGE_LINGYAOHECHENGPANELCTR_NPOINT_CHANGE, { b = b });

       end

    end

end

function LingYaoHeChengPanelCtr:UpShowListItem(v)
self.leftPCtr:UpShowListItem(v)
end


function LingYaoHeChengPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LingYaoHeChengPanelCtr:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function LingYaoHeChengPanelCtr:Dispose()


    if self.leftPCtr ~= nil then
        self.leftPCtr:Dispose();
         self.leftPCtr = nil;
    end

     self.panel_left = nil;
   
    self.gameObject = nil;

end