local tbUi = Ui:CreateClass("BuffTip2")

local nBgNum = 4;                               --控制背景图的大小
local nScrollViewHeight = 420;                  --ScrollView高度

local nSlideNum = nBgNum - 1;              

function tbUi:OnOpen(nBuffId, nLevel)
    self.tbBuffSkillId = {
        {
            nSkillId = nBuffId,
            nSkillLevel = nLevel,
        },
    }
    self:UpdateBuffInfo()
end

function tbUi:OnOpenEnd()
    self:UpdateBGHeight()
end

function tbUi:UpdateBGHeight()
    if #self.tbBuffSkillId >= nBgNum then                   --控制背景的最小高度
        self.nAllTxtHeight = nScrollViewHeight + 20
    end
    self.pPanel:Widget_SetSize("BuffTipBg1", 460, self.nAllTxtHeight);
end

function tbUi:UpdateBuffInfo()
        local tbTxtHeight = {};
        self.nAllTxtHeight = 0;
        local i = 1;
        local fnSetItem = function(itemObj, nIdx)
            if self.tbBuffSkillId[nIdx] and self.tbBuffSkillId[nIdx].nSkillId then
                local nSkillId = self.tbBuffSkillId[nIdx].nSkillId;
                local nSkillLevel = self.tbBuffSkillId[nIdx].nSkillLevel;
                local tbMagic     = self.tbBuffSkillId[nIdx].tbMagic;

                FightSkill.bCalcValue = true;
                local _, szMsg = Lib:CallBack({FightSkill.GetSkillStateMagicDesc, FightSkill, nSkillId, nSkillLevel, tbMagic});
                itemObj.pPanel:Label_SetText("Effect", szMsg);
                FightSkill.bCalcValue = nil;
                itemObj.pPanel:SetActive("TimeTitle",false);
                itemObj.pPanel:SetActive("Time",false);

                local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel);
                itemObj.pPanel:Sprite_SetSprite("BUFF", tbStateEffect.Icon, tbStateEffect.IconAtlas);
                itemObj.pPanel:Label_SetText("BUFFName", tbStateEffect.StateName or ""); 

                itemObj.nSkillId = nSkillId;
                itemObj.szBuffMsg = szMsg or "";

                local nTxtHeight = self:GetObjHeight(itemObj); 
                tbTxtHeight[nIdx] = nTxtHeight;
                itemObj.pPanel:SetActive("Main", true);
                itemObj.pPanel:Widget_SetSize("Main", 420, nTxtHeight);
                self.ScrollView:UpdateItemHeight(tbTxtHeight);
                if i <= nBgNum then                         -- 背景显示大小
                    self.nAllTxtHeight = self.nAllTxtHeight + nTxtHeight;
                    i = i + 1;
                end

                if #self.tbBuffSkillId <= nSlideNum then           -- 控制可滑动范围
                    itemObj.pPanel:SetBoxColliderEnable("Main", false)
                else
                    itemObj.pPanel:SetBoxColliderEnable("Main", true)
                end
            end
        end
        self.ScrollView:UpdateItemHeight({100});                    -- 初始化高度
        self.ScrollView:Update(#self.tbBuffSkillId, fnSetItem);
        self.ScrollView:GoTop();
end

function tbUi:GetObjHeight(itemObj)
    local TxtSize = itemObj.pPanel:Label_GetPrintSize("Effect");
    return TxtSize and (50 + TxtSize.y + 10) or 160;
end

function tbUi:OnClose()
    self.pPanel:SpringPanel_SetEnabled("ScrollView",false);
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end
