require "Core.Module.InstancePanel.View.items.GiftItem"
require "Core.Manager.Item.ZongMenLiLianDataManager"

ZMLLBottomPanelCtr = class("ZMLLBottomPanelCtr");

function ZMLLBottomPanelCtr:New()
    self = { };
    setmetatable(self, { __index = ZMLLBottomPanelCtr });
    return self
end


function ZMLLBottomPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.label1Txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "label1Txt");
    self.label2Txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "label2Txt");
    self.label3Txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "label3Txt");
    self.label4Txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "label4Txt");

    self.fbdecTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fbdecTxt");



    for i = 1, 4 do
        self["product" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end

    MessageManager.AddListener(ZongMenLiLianItem, ZongMenLiLianItem.MESSAGE_ITEM_SELECTED_CHANGE, ZMLLBottomPanelCtr.ItemSelectedHandler, self);

    MessageManager.AddListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_GETZONGMENINFO_COMPLETE, ZMLLBottomPanelCtr.SampleDataChange, self);


end


function ZMLLBottomPanelCtr:ItemSelectedHandler(target)
    self:SetData(target.data)
end

function ZMLLBottomPanelCtr:SampleDataChange()

    local actData = ActivityDataManager.config[ActivityDataManager.interface_id_25];

    local sampleData = ZongMenLiLianDataManager.sampleData;

    

    if sampleData ~= nil then

        local t = sampleData.t;
        local a = sampleData.a;

        self.label3Txt.text = LanguageMgr.Get("ZongMenLiLian/ZMLLBottomPanelCtr/label1") .. t .. "/" .. actData.activity_times;

        if a > actData.max_degree then
            a = actData.max_degree;
        end

        self.label4Txt.text = LanguageMgr.Get("ZongMenLiLian/ZMLLBottomPanelCtr/label2") .. a .. "/" .. actData.max_degree;

    end

   

end


--[[
15:54:41.137-486: --order= [2]
--instance_id= [0]
--id= [2]
--type_name= [宗门历练]
--min_level= [50]
drop--1= [4_1]
|    --2= [1_1]
|    --3= [111_1]
|    --4= [102_1]
--desc= [各大宗门为了提升本门实力，共同对抗魔主，纷纷派出弟子前往中天各地历练]
--down_float= [15]
--icon_id= [fb_xyj]
--max_level= [100]
--type= [1]
--up_float= [20]
--name= [宗门历练-50级]
--activity_id= [25]
]]
function ZMLLBottomPanelCtr:SetData(data)

    self.data = data;


    local drop = self.data.drop;
    local t_num = table.getn(drop);

    for i = 1, t_num do
        local reward = drop[i];
        local info = string.split(reward, "_");

        local spid = info[1] + 0;
        local _num = info[2] + 0;

        local pinfo = ProductManager.GetProductInfoById(spid, _num);
        self["productCtr" .. i]:SetData(pinfo);
    end

    self.fbdecTxt.text = data.desc;
   self.label1Txt.text = LanguageMgr.Get("ZongMenLiLian/ZMLLBottomPanelCtr/label3") .. self.data.min_level;

     self:SampleDataChange();

end



function ZMLLBottomPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function ZMLLBottomPanelCtr:Hide()


    self.gameObject.gameObject:SetActive(false);
end

function ZMLLBottomPanelCtr:Dispose()



    for i = 1, 4 do
        self["productCtr" .. i]:Dispose();
        self["productCtr" .. i] = nil;
        self["product" .. i] = nil;
    end

    MessageManager.RemoveListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_GETZONGMENINFO_COMPLETE, ZMLLBottomPanelCtr.SampleDataChange);
    MessageManager.RemoveListener(ZongMenLiLianItem, ZongMenLiLianItem.MESSAGE_ITEM_SELECTED_CHANGE, ZMLLBottomPanelCtr.ItemSelectedHandler);

    self.gameObject = nil;

    self.label1Txt = nil;
    self.label2Txt = nil;
    self.label3Txt = nil;
    self.label4Txt = nil;

    self.fbdecTxt = nil;



end