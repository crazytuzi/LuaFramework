SeparateFrameUtil = {}

--分帧操作
--op_call_back(cur_frame_count,cur_all_count)  --操作回调 cur_frame_count:当前执行的是当前帧的第几个操作 cur_all_count 当前执行的是迄今为止的第几个操作
--inteval 间隔时间，nil则为间隔一帧
--one_frame_op_count 单帧操作数量
--all_frame_op_count 所有操作数量
--one_frame_op_complete 单帧的所有操作结束时的回调
--all_frame_op_complete 所有操作结束时的回调
function SeparateFrameUtil.SeparateFrameOperate(op_call_back,interval,one_frame_op_count,all_frame_op_count,one_frame_op_complete,all_frame_op_complete)
    local schedule_id = nil

    local all_counter = 1

    local function call_back()
        for i=1,one_frame_op_count do
            if op_call_back then
               --执行操作
               op_call_back(i,all_counter)
            end
        
            if all_counter >= all_frame_op_count then
                --所有操作结束
                GlobalSchedule:Stop(schedule_id)
                if one_frame_op_complete then
                    one_frame_op_complete()
                end
                
                if all_frame_op_complete then
                    all_frame_op_complete()
                end
                return
            end

            --增加计数
            all_counter = all_counter + 1
        end

        --一个帧的所有操作结束
        if one_frame_op_complete then
            one_frame_op_complete()
        end

       
    end
    schedule_id = GlobalSchedule:Start(call_back,interval)

    return schedule_id
end