dailyNewsVo={}
function dailyNewsVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function dailyNewsVo:initWithData(data)
    if data then
        self.id = tonumber(data.id)
        self.type = data.type      --类型
        self.content = data.content or ""   --内容文字
        -- self.praiseNum = data.praiseNum or 0    --点赞数量
        -- self.isHeadlines = data.isHeadlines or 0    --是否头条
        self.pic = data.pic or 1
        -- self.comment = data.comment or 0         --选择第几条评论，序号(0则未选)

        -- {图片,名字,等级,战力,军团,id}
        self.userinfo = data.userinfo               --个人信息
        -- {军团名字,等级,团长,战力,最大人数,当前人数,加入军团方式,等级限制（加入条件）,战力限制（加入条件）,军团宣言,id}
        self.allianceinfo = data.allianceinfo       --军团信息
        -- {名字,服务器,战力,赛季,图片}
        self.skyladderUser = data.skyladderUser     --天梯榜个人信息
        -- {名字,服务器,战力,赛季,图片}
        self.skyladderAlliance = data.skyladderAlliance --天梯榜军团信息


        self.num = {}
        self.other={}

        --头条信息
        self.praiseNum = tonumber(data.praiseNum) or 0    --点赞数量
        self.comment = tonumber(data.comment) or 0        --选择第几条评论，序号(0则未选)
        self.commentPlayer = data.commentPlayer or ""   --评论玩家名字
    end
end



