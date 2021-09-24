--
-- desc:问卷调查
-- user:chenyunhe
--

function model_questions()
    local self = {
        rkey = '',
    }

    function self.bind()
        local questions = self.getValid()
        if type(questions) == 'table' then
            for k,v in pairs(questions) do
                self[tostring(v.qid)] = v 
            end
        end
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then              
                data[k] = v
            end
        end
        return data
    end

    -- 根据问卷id获取数据
    function self.getByid(qid)
        local question = {}
        local db = getDbo()
        local result = db:getRow("select `qid`,`st`,`et`,`time`,`level`,`title`,`content`,`gift` from questions where qid = :qid ",{qid=qid})

        if result then
            question = result
        end       
        return question 
    end

    function self.getValid()    
        local ts = getClientTs()
        local redis = getRedis()
        local questions = redis:hgetall(self.rkey)

        if type(questions) ~= 'table' or not(next(questions)) then
            local db = getDbo()
            local result = db:getAllRows("select `id`,`qid`,`st`,`et`,`time`,`level`,`title`,`content`,`gift` from questions where st <= :st and et > :currTs ",{currTs=ts,st=ts})
            if result then
                questions = result
                for k,v in pairs(result) do
                    redis:hmset(self.rkey,v.qid,json.encode(v))
                end
                redis:expire(self.rkey,3600)
            else
                return false
            end    
        else
            for k,v in pairs(questions) do
                questions[k] = json.decode(v)  or v
            end
        end
        
        return questions 
    end

    -- 更新问卷数据
    function self.set(qid,params)
        params.updated_at = getClientTs()    

        local db = getDbo()            
        local ret = db:update("questions",params,"qid='".. (db.conn:escape(qid) or 0) .. "'")        

        if ret and ret > 0 then
            local redis = getRedis()
            redis:del(self.rkey)
            return true 
        end
    end

    -- 创建问卷
    function self.create(params)
        params.updated_at = getClientTs()    
        local db = getDbo()
        local ret = db:insert("questions",params)

        if ret and ret > 0 then
            local redis = getRedis()
            redis:del(self.rkey) 
            return true
        end
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".questions"
    end

    function self.list(uid)
        local r = {}
        local finished = self.ufinish(uid)
        local questions = self.getValid()
        if type(questions)=='table' and next(questions) then
            for k,v in pairs(questions) do
                if not table.contains(finished,tonumber(v.qid)) then
                     table.insert(r,{tonumber(v.qid),v.title,tonumber(v.level),tonumber(v.et)})
                end
            end
        end

        return r
    end

    function self.ufinish(uid)
        local finished = {}
        local db = getDbo()
        local result = db:getAllRows("select `qid` from answers where uid=:uid ",{uid=uid})
   
        if result then
            for k,v in pairs(result) do
                table.insert(finished,tonumber(v.qid))
            end  
        end

        return finished
    end

    function self.sub(uid,qid,params)
        params.updated_at = getClientTs()    
        local db = getDbo()
        local ret = db:insert("answers",params)

        if ret and ret > 0 then
            return true
        end
        return false
    end

    function self.check(uid,qid)
        local db = getDbo()
        local result = db:getRow("select * from answers where uid=:uid  and qid = :qid ",{uid=uid,qid=qid})
        if result then
            return true
        end

        return false
    end

    function self.statistics(qid,ans,uid)
        local statistics ={}
        local db = getDbo()
        local result = db:getRow("select `content`,`statistics` from questions where qid = :qid ",{qid=qid})
        local content = json.decode(result.content)
        if result then
            statistics = json.decode(result.statistics)
        end

        local an = {"A","B","C","D","E","F","G"}
        for k,v in pairs(content) do
            if not statistics[k] then
                statistics[k] = {}
            end
            for rk,rv in pairs(v[2]) do
                local a = an[rk]
                statistics[k][a] = statistics[k][a] or 0
                if ans[k] and ans[k]==rk then
                    statistics[k][a] = statistics[k][a] + 1
                end    
            end
        end

        local params = {
             statistics= statistics
         }

        local ret = db:update("questions",params,"qid='".. (db.conn:escape(qid) or 0) .. "'")
        if ret<=0 then
            writeLog('statis:uid='..uid..'--qid='..qid,'questions_error')
        end
    end

    -- 获取统计结果
    function self.getstatistics(qid)
        local r = {}
        local db = getDbo()
        local result = db:getRow("select `statistics` from questions where qid = :qid ",{qid=qid})
        if result then
            r = json.decode(result.statistics)
        end       
        return r 
    end

    self.setRkey()
    self.bind()

    return self

end