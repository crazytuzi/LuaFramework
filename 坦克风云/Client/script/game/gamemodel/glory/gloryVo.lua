gloryVo={}

function gloryVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--bm 战报字段
function gloryVo:initWithData(data)
        if data.boom then --当前繁荣度
            self.curBoom = data.boom 
            self.baseCurBoom = data.boom
        end
        if self.curBoom ==nil then
            self.curBoom =0
        end
        if self.baseCurBoom ==nil then
            self.baseCurBoom =0
        end

        if data.boom_max then --当前繁荣度 上限！！
            self.curBoomMax = data.boom_max
        end
        if self.curBoomMax ==nil then
            self.curBoomMax =0
        end

        if data.boom_ts then --后台返回最新繁荣度刷新时间
            self.boom_ts = data.boom_ts
        end

        if data.bmd then
            self.isGloryOver =data.bmd
        end
        if self.isGloryOver ==nil then
            self.isGloryOver =0
        end

        if self.isOtherPlayerBmd ==nil then
            self.isOtherPlayerBmd =0
        end

        if self.tbX ==nil then
            self.tbX =0
        end
        if self.tbY ==nil then
            self.tbY =0
        end
end