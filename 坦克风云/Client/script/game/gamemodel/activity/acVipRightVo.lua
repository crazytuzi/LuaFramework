acVipRightVo=activityVo:new()
function acVipRightVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    self.acCfg={}
	self.buyItems={}
    self.lastBuyTime=0

	return nc
end

function acVipRightVo:updateSpecialData(data)
    if data.reward then
        if data.reward.boxCfg then
            self.acCfg=data.reward.boxCfg
        end
    end
    if data.ts then
        self.lastBuyTime=tonumber(data.ts) or 0
    end
    if data.d then  
        local goods={}
        local items=data.d
        for k,v in pairs(items) do
            if G_isToday(self.lastBuyTime)==false then
                v=0
            end
            local isHas=false
            for m,n in pairs(self.buyItems) do
                if n and n.key and k==n.key then
                    self.buyItems[m].num=tonumber(v)
                    isHas=true
                end
            end
            if isHas==false then
                local name,pic,desc,id,index,eType,equipId=getItem(k,"p")
                table.insert(self.buyItems,{name=name,num=v,pic=pic,desc=desc,id=id,type="p",index=index,key=k,eType=eType,equipId=equipId})
                
            end
            -- if G_isToday(self.lastBuyTime)==false then
            --     v=0
            -- end
            -- local name,pic,desc,id,index,eType,equipId=getItem(k,"p")
            -- table.insert(goods,{name=name,num=v,pic=pic,desc=desc,id=id,type="p",index=index,key=k,eType=eType,equipId=equipId})
        end
        -- self.buyItems=goods
        local function sortAsc(a, b)
            if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                return tonumber(a.id) < tonumber(b.id)
            end
        end
        table.sort(self.buyItems,sortAsc)
    end
    
end
