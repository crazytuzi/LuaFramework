
local tbUi = Ui:CreateClass("BuffTip");

local nBgNum = 4;                               --控制背景图的大小
local nScrollViewHeight = 420;                  --ScrollView高度

local nSlideNum = nBgNum - 1;              

function tbUi:OnOpen(tbBuffSkill)

   self:ClearItemObjFlag();                     -- 失效的itemObj虽然看不见但数据还是在的，所以要先把标志清掉
   self:UpdateBuffSkill(tbBuffSkill)
   self:UpdateBuffInfo()
end

function tbUi:UpdateBuffSkill(tbBuffSkill)
    self.tbBuffSkillId = {}
    local pNpc = me.GetNpc();
    if not pNpc then
        return
    end
    local i = 1
    for _,tbBuffInfo in ipairs(tbBuffSkill or {}) do
        local nSkillId = tbBuffInfo.nSkillId
        local tbState = pNpc.GetSkillState(nSkillId);
        if tbState and tbState.nEndFrame > 0 then
            self.tbBuffSkillId[i] = {nSkillId = tbState.nSkillId,nSkillLevel = tbState.nSkillLevel, tbMagic = tbState.tbAttrib};
            i = i + 1
        end
   end
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

function tbUi:ClearItemObjFlag()                    
    for Idx = 0, 100 do
        local szItemObj = "Item" ..Idx;
        local itemObj = self.ScrollView.Grid[szItemObj]
        if itemObj then
            itemObj.nSkillId = nil;
        else
            break;
        end
    end
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
                local _, szMsg = Lib:CallBack({FightSkill.GetSkillStateMagicDesc, FightSkill, nSkillId, nSkillLevel, tbMagic, true});
                FightSkill.bCalcValue = nil;
                itemObj.pPanel:SetActive("TimeTitle",false);
                itemObj.pPanel:SetActive("Time",false);

                local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel);
                itemObj.pPanel:Sprite_SetSprite("BUFF", tbStateEffect.Icon, tbStateEffect.IconAtlas);
                local szName = tbStateEffect.StateName or ""
                local szSkillStyleName = FightSkill:GetSkillStyleDesc(nSkillId) or ""
                itemObj.pPanel:Label_SetText("BUFFName", szName .. szSkillStyleName); 

                itemObj.nSkillId = nSkillId;
                itemObj.szBuffMsg = szMsg or "";

                self:UpdateRemainTime(itemObj)
                
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
        self:CloseTimer();
        self.nTimeTimer = Timer:Register(Env.GAME_FPS, self.UpdateTime, self);
end

function tbUi:UpdateTime()

    if not self.tbBuffSkillId or not next(self.tbBuffSkillId) then           -- 所有的buff都失效
         Ui:CloseWindow(self.UI_NAME); 
        return
    end

    for Idx = 0, 100 do
        local szItemObj = "Item" ..Idx;
        local itemObj = self.ScrollView.Grid[szItemObj]                      
        if not itemObj or not itemObj.nSkillId then                      -- 防止使用过失效的itemObj
           break
        end
        self:UpdateRemainTime(itemObj)
    end

    return true;
end

function tbUi:UpdateRemainTime(itemObj)
     local nFrame = 0;
    local fTime = 0;
    local szMsg = "";
    local pNpc = me.GetNpc();
    local tbState =  pNpc and pNpc.GetSkillState(itemObj.nSkillId);
    if tbState and tbState.nEndFrame > 0 then
       nFrame = (tbState.nEndFrame - GetFrame());
       fTime = nFrame / Env.GAME_FPS;
       if fTime < 0 then
          fTime = 0;
       end
       local szTime = Lib:TimeDesc(fTime);
       local tbStateInfo = FightSkill:GetStateEffectBySkill(itemObj.nSkillId, tbState.nSkillLevel);
       szMsg = (itemObj.szBuffMsg or "");
       if not tbStateInfo or tbStateInfo.NotShowTime ~= 1 then
            szMsg = szMsg..string.format("\n[92d2ff]剩余时间[-]：[ffffff]%s[-]", szTime);
       end
       
       itemObj.pPanel:Label_SetText("Effect", szMsg);
       itemObj.pPanel:Label_SetText("Time", szTime);
    else
        self:OnBuffEffectEnd();
    end
end

function tbUi:OnBuffEffectEnd()
    self:CloseTimer();
    self:UpdateBuffSkill(self.tbBuffSkillId or {})
    if not self.tbBuffSkillId or not next(self.tbBuffSkillId) then
        Ui:CloseWindow(self.UI_NAME); 
        return 
    end
    Timer:Register(1, function()
        self:ClearItemObjFlag();
        self:UpdateBuffInfo();
        self:UpdateBGHeight();
     end);
end

function tbUi:GetObjHeight(itemObj)
    local TxtSize = itemObj.pPanel:Label_GetPrintSize("Effect");
    return TxtSize and (50 + TxtSize.y + 10) or 160;
end

function tbUi:CloseTimer()
    if self.nTimeTimer then
        Timer:Close(self.nTimeTimer);
        self.nTimeTimer = nil;
    end    
end

function tbUi:OnClose()
    self.pPanel:SpringPanel_SetEnabled("ScrollView",false);
    self:CloseTimer();
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end
