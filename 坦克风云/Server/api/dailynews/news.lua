local function api_dailynews_news()
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.before(request)
        
    end

    function self.action_process()
        local response = self.response
        
        if switchIsEnabled('dnews') then
            local mDailyNews = loadModel("model.dailynews")
            mDailyNews:process()
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        获取登录奖励(感恩有您和欢迎回家)
        活动开启后,活跃玩家或回归玩家都会获得一份奖励
    ]] 
    function self.action_list(request)
        local response = self.response
        local uid = request.uid
        local mDailyNews = loadModel("model.dailynews")

        -- 取昨日生成的数据
        local day = mDailyNews.day-1
        local newsList = mDailyNews:getArticlesFromDb(day)
        local headline = mDailyNews:getHeadlineFromDb(day)

        for k,v in pairs(newsList) do
            v.content = json.decode(v.content)
        end

        if type(headline) == 'table' then
            headline.content = json.decode(headline.content)
        end

        response.isVote = mDailyNews:isVote(uid)
        response.data.newsList = newsList
        response.data.headline = headline
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 好评
    function self.action_vote(request)
        local response = self.response
        local uid = request.uid
        local newsId = request.params.newsId
        local mDailyNews = loadModel("model.dailynews")

        -- 每日操作次数达到上限
        if mDailyNews:isVote(uid) then
            response.ret = -1973
            return response
        end

        local headline = mDailyNews:getHeadlineById(newsId)

        if headline then
            mDailyNews:updateHeadLine{
                id=headline.id,
                goodpost=headline.goodpost+1,
            }

            mDailyNews:setVoteUser(uid)
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置评论
    function self.action_comment(request)
        local response = self.response
        local uid = request.uid
        local newsId = request.params.newsId
        local commenter = request.params.commenter or ""
        local comment = request.params.comment
        local mDailyNews = loadModel("model.dailynews")

        local headline = mDailyNews:getHeadlineById(newsId)

        if headline then
            if tonumber(headline.comment) > 0 then
                response.ret = -1973
                return response
            end

            mDailyNews:updateHeadLine{
                id=headline.id,
                comment=comment,
                commenter=commenter,
            }
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function function_name( ... )
        -- body
    end

    function self.after()
    end

    return self
end

return api_dailynews_news