
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 25, text = "@1",
            maxWidth = 500,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =1.5,
        },},
    {delay = {time = 0.5,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },








jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},},



qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -101,
            file  = "bj.png",
        },
    },


    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },
    {
        model = {
            tag   = "map0",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1020, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(900, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    -- {
    --     model = {
    --         tag   = "map11",
    --         type  = DEF.PIC,
    --         scaleX = 1,scaleY = 1.2,
    --         pos   = cc.p(900, 0),
    --         order = -100,
    --         file  = "huangye.jpg",
    --         parent= "clip_1",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(2820, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
    },






    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

	{
        music = {file = "backgroundmusic5.mp3",},
    },


     -- {
     --     load = {tmpl = "zm",
     --         params = {TR("你私自放走小龙女的事被暴露，"),"900"},},
     -- },

     -- {
     --     load = {tmpl = "zm",
     --         params = {TR("你的美女师父非常生气。"),"850"},},
     -- },

     -- {
     --     load = {tmpl = "zm",
     --         params = {TR("你本想好好哄哄你的师父，"),"800"},},
     -- },

     -- {
     --     load = {tmpl = "zm",
     --         params = {TR("然而接下来发生的事，"),"750"},},
     -- },

     -- {
     --     load = {tmpl = "zm",
     --         params = {TR("却一切变得无法挽回……"),"700"},},
     -- },


    -- {delay = {time = 0.5,},},





    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("面对去而复返的杨过，"),"600"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("小龙女心中满是欢喜，"),"550"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("躺在杨过的怀中，"),"500"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("小龙女心中柔肠千结，"),"450"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("似有千般言语想要倾诉……"),"400"},},
    --  },


    -- {delay = {time = 2.4,},},

    -- {remove = { model = {"900", "850", "800","750", "700", }, },},

    -- {remove = { model = {"600", "550", "500", "450", "400",}, },},


    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-400,0),    order     = 50,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.2,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,10),
        },},
    -- {
    --     model = {
    --         tag   = "xue1",
    --         type  = DEF.PIC,
    --         scaleX = 0.4,scaleY = 0.5,
    --         pos   = cc.p(-220, 400),
    --         order = 100,
    --         file  = "xue1.png",
    --         parent= "lwshuang",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","-100","-280"},},
     },
    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情

     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.8","3","-2800","-1000"},},
     -- },






    -- {remove = { model = {"lwshuang", }, },},
    -- {   model = {
    --         tag  = "lwshuang",     type  = DEF.FIGURE,
    --         pos= cc.p(0,100),    order     = 50,
    --         file = "hero_luwushuang",    animation = "yun",
    --         scale = 0.2,   parent = "clip_1", speed = 0.6,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 1.2,by = cc.p(600,100),},},},},



        -- {action = { tag  = "lwshuang",sync = true,what = {spawn={{scaleY= {time = 0.8,to = 0.05,},},
        --           {move = { time = 0.8,by = cc.p(0,240),},},},},},},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","2","0.8","-600","-280"},},
     },

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 2.5,by = cc.p(630,250),},},},},


    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(830,350),    order     = 50,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.2,   parent = "clip_1", speed = 0,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,15),
        },},

    -- {
    --     model = {
    --         tag   = "xue1",
    --         type  = DEF.PIC,
    --         scaleX = 0.4,scaleY = 0.5,
    --         pos   = cc.p(-100, 1000),
    --         order = 100,
    --         file  = "xue1.png",
    --         parent= "lwshuang",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","-450","-200"},},
     },

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,300),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.2,to = cc.p(450,300),
                                 control={cc.p(0,300),cc.p(450,600),}
    },},},
    },},},


    {
       delay = {time = 0.2,},
    },
    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"oyk",TR("你逃不了的，我一定会让你十分悲惨的死去，哈哈哈哈！"),"1253.mp3"},},
     },
     {
         load = {tmpl = "talk0",
             params = {"oyk",TR("不过在你死之前，先让我好好享受享受——玩弄猎物的愉悦吧！"),"5031.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"oyk",TR("哈哈哈哈！挣扎吧！挣扎吧！我最喜欢将猎物慢慢折磨而死！"),"1261.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },













    {   model = {
            tag  = "cxfeng",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 80,
            file = "hero_chenxuanfeng",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "cxfeng",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.2,to = cc.p(300,150),
                                 control={cc.p(0,0),cc.p(150,600),}
    },},},
    },},},


     {
         load = {tmpl = "move1",
             params = {"cxf","cxf.png",TR("陈玄风")},},
     },

     {
         load = {tmpl = "talk",
             params = {"cxf",TR("好了，快点杀了她，别忘了老妖婆交代我们的事！"),"1263.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"cxf"},},
    },


     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"oyk",TR("好吧，好吧！真是可惜——难得有这么令人心动的猎物！"),"5032.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"oyk",TR("那么！小美人儿，你准备好——迎接死亡了吗！"),"5033.mp3"},},
     },




     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","-500","-200"},},
     },

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1500,200),    order     = 60,
            file = "_lead_",    animation = "pose",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.9, rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.2,},},
    {bezier = {time = 0.4,to = cc.p(1100,200),
                                 control={cc.p(1500,200),cc.p(1300,600),}
    },},},
    },},},

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1100,200),    order     = 60,
            file = "_lead_",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("住手！你这个疯子！"),"5034.mp3"},},
     },




    {
       delay = {time = 0.6,},
    },
    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(450,300),    order     = 70,
            file = "hero_ouyangke",    animation = "win",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

     {
         load = {tmpl = "talk1",
             params = {"oyk",TR("嗯？似乎来了一只更有趣的猎物！"),"5035.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"oyk",TR("哈哈哈！那么，就再来一场完美的猎杀吧！"),"5036.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"oyk","zj"},},
    },

    {remove = { model = {"text-board", }, },},
     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.2","0.7","-900","-200"},},
     },


    {   model = {
            tag  = "oyke1",     type  = DEF.FIGURE,
            pos= cc.p(450,300),    order     = 70,
            file = "hero_ouyangke",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 2,opacity=155,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "oyke2",     type  = DEF.FIGURE,
            pos= cc.p(450,300),    order     = 70,
            file = "hero_ouyangke",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 1.5,opacity=155,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {
        sound = {file = "hero_ouyangke_pugong.mp3",sync=false,},
    },
    {action = {tag  = "oyke1",sync = false,what ={ spawn={{scale= {time = 1.2,to = 0.2,},},
    {bezier = {time = 1.2,to = cc.p(1500,200),
                                 control={cc.p(450,300),cc.p(800,500),}
    },},},
    },},},

    {action = {tag  = "oyke2",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 1.6,to = cc.p(1500,200),
                                 control={cc.p(450,300),cc.p(800,500),}
    },},},
    },},},


    {
       delay = {time = 0.3,},
    },


    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1100,200),    order     = 60,
            file = "_lead_",    animation = "pugong",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,180,0),
        },},


    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 1.2,to = cc.p(1700,200),
                                 control={cc.p(1100,200),cc.p(1300,200),}
    },},},
    },},},



    {
       delay = {time = 0.6,},
    },
    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(450,300),    order     = 70,
            file = "hero_ouyangke",    animation = "nuji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},



    {
        sound = {file = "hero_ouyangke_nuji.mp3",sync=false,},
    },

    {action = {tag  = "oyke",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 1.5,to = cc.p(1500,200),
                                 control={cc.p(450,300),cc.p(800,500),}
    },},},
    },},},




    {
       delay = {time = 0.3,},
    },

    {remove = { model = {"oyke1", }, },},

    {
       delay = {time = 0.4,},
    },
    {remove = { model = {"oyke2", }, },},

    {
       delay = {time = 0.5,},
    },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1700,200),    order     = 60,
            file = "_lead_",    animation = "aida",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.4,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.4,to = cc.p(1200,200),
                                 control={cc.p(1500,200),cc.p(1350,200),}
    },},},
    },},},



    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1700,200),    order     = 60,
            file = "_lead_",    animation = "soushang",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},
    {
       delay = {time = 0.6,},
    },


    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "win",
            scale = 0.2,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("小子，你就好好欣赏欣赏我料理猎物的手段吧！希望你会喜欢！"),"5037.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },















    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "win",
            scale = 0.2,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.2","0.7","-700","-200"},},
     },


    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("不要——！"),"5039.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"zj"},},
    },


    {   model = {
            tag  = "oyke1",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 1.5,opacity=155,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "hero_ouyangke_pugong.mp3",sync=false,},
    },

    {
       delay = {time = 0.5,},
    },

    {action = {tag  = "oyke1",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.2,},},
    {bezier = {time = 0.2,to = cc.p(1000,350),
                                 control={cc.p(1200,200),cc.p(1100,300),}
    },},},
    },},},

    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(830,350),    order     = 50,
            file = "hero_luwushuang",    animation = "aida",
            scale = 0.2,   parent = "clip_1", speed = 0.7,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,15),
        },},

    {
       delay = {time = 0.4,},
    },
    {remove = { model = {"oyke1", }, },},
    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 1.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.4,},
    },

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(830,350),    order     = 50,
            file = "hero_luwushuang",    animation = "yun",
            scale = 0.2,   parent = "clip_1", speed = 0,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,15),
        },},

     {
         load = {tmpl = "move1",
             params = {"lws","lws.png",TR("陆无双")},},
     },
    {
        model = {
            tag   = "xue3",
            type  = DEF.PIC,
            scaleX = 0.36,scaleY = 0.35,
            pos   = cc.p(437, 662),
            order = 100,
            file  = "xue1.png",
            parent= "lws", opacity=255,
            rotation3D=cc.vec3(0,0,0),
        },
    },



     {
         load = {tmpl = "talk",
             params = {"lws",TR("啊！"),"5038.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"lws"},},
    },



    {action = {tag  = "lwshuang",sync = false,what ={ spawn={{move= {time = 2.2,to = cc.p(700,360),},},
    {rotate = {to = cc.vec3(0, 180, 60),time = 2.2,},},},},},},


    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1800,200),    order     = 60,
            file = "_lead_",    animation = "soushang",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 1.1,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.2","0.7","-1000","-200"},},
     },


    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 1.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("哈哈哈！我就喜欢看你们这些孱弱之人无力挣扎的样子！"),"5040.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },




	{
        music = {file = "jq_jy1.mp3",},
    },

    {
        sound = {file = "5041.mp3",sync=false,},
    },


    {
        model = { tag = "yupan",type  = DEF.PIC,
                  file  = "yp.png",order = 100,scale=0.01,
                  pos   = cc.p(1800, 200),parent = "clip_1",rotation3D=cc.vec3(0,0,0),},
    },

    {
        model = {
            tag       = "xiangzi",     type      = DEF.FIGURE,
            pos= cc.p(450,500),     order     = 101,
            file      = "effect_jinlun",         animation = "animation",
            scale     = 1.3,         loop      = true,
            endRlease = false,         parent = "yupan", speed=2,
        },},

    {
        model = {
            tag       = "guangxiao",     type      = DEF.FIGURE,
            pos= cc.p(300,400),     order     = 40,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 8,        loop      = true,opacity=150,
            endRlease = false,         parent = "yupan", speed=0.8,rotation3D=cc.vec3(0,0,0),
        },},
    {
        model = {
            tag       = "guangxiao2",     type      = DEF.FIGURE,
            pos= cc.p(500,400),     order     = 41,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 8,        loop      = true,opacity=250,
            endRlease = false,         parent = "yupan", speed=1.2,rotation3D=cc.vec3(0,180,-20),
        },},

    {
        model = {
            tag       = "guangxiao3",     type      = DEF.FIGURE,
            pos= cc.p(300,200),     order     = 80,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 10,        loop      = true,opacity=150,
            endRlease = false,         parent = "yupan", speed=0.8,rotation3D=cc.vec3(0,0,0),
        },},
    {
        model = {
            tag       = "guangxiao4",     type      = DEF.FIGURE,
            pos= cc.p(500,200),     order     = 81,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 12,        loop      = true,opacity=250,
            endRlease = false,         parent = "yupan", speed=1.2,rotation3D=cc.vec3(0,180,0),
        },},


    {
        sound = {file = "biwu.mp3",sync=false,},
    },


    {action = {tag  = "yupan",sync = true,what ={ spawn={{move= {time = 0.8,by = cc.p(0,400),},},
    {scale = {to = 0.2,time = 0.8,},},},},},},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.2","0.6","-900","-100"},},
     },


     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("这……你这是怎么回事？"),"5042.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },



     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("三尺青锋剑！"),"50431.mp3"},},
     },



    {   model = {
            tag  = "heihua1",     type  = DEF.FIGURE,
            pos= cc.p(50,-100),    order     = -10,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 4.5,    parent = "zjue", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "heihua1",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua2",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = -60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "heihua2",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua3",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua3",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua4",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = -60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua4",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua5",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua5",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua6",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = -60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua6",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua7",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua7",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua8",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua8",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


   {
        delay = {time = 0.25,},
    },
     {
         load = {tmpl = "talk0",
             params = {"zj",TR("七寸碧血刀！"),"50432.mp3"},},
     },



        {action = { tag  = "heihua1",sync = true,what = {scale = {
                   time = 0.01,to = 6,},},},},
   {
        delay = {time = 0.25,},
    },
     {
         load = {tmpl = "talk0",
             params = {"zj",TR("我意入轮回！"),"50433.mp3"},},
     },
        {action = { tag  = "heihua1",sync = true,what = {scale = {
                   time = 0.01,to = 7.5,},},},},

   {
        delay = {time = 0.25,},
    },
     {
         load = {tmpl = "talk2",
             params = {"zj",TR("杀他万恶消！"),"50434.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"zj"},},
    },

        {action = { tag  = "heihua1",sync = true,what = {scale = {
                   time = 0.01,to = 9,},},},},


    -- {   model = {
    --         tag  = "long1",     type  = DEF.FIGURE,
    --         pos= cc.p(1500,0),    order     = 30,
    --         file = "effect_wg_xianglongzhang",    animation = "animation",
    --         scale = 0.3,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,180,0),
    --     },},

    -- {action = {tag  = "long1",sync = false,what = {loop = {sequence = {
    --              {move = {time = 0.4,by = cc.p(0,0),},},
    --              {fadeout = {time = 0.1,},},
    --              {move = {time = 0.75,by = cc.p(0,0),},},
    --              {fadein = {time = 0.183,},},},},},},},
    -- {action = {tag  = "long1",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    -- {bezier = {time = 0.7,to = cc.p(1500,0),
    --                              control={cc.p(1500,200),cc.p(1500,-200),}
    -- },},},},
    -- },},},



     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("啊——！不——！"),"5044.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","2","0.6","-800","-100"},},
     },

    {   model = {
            tag  = "zjue1",     type  = DEF.FIGURE,
            pos= cc.p(1800,200),    order     = 70,
            file = "_lead_",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 1.5,opacity=125,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "long1",     type  = DEF.FIGURE,
            pos= cc.p(1600,300),    order     = 80,
            file = "effect_wg_kongmingquan",    animation = "bao",
            scaleX = 1, scaleY = 2,   parent = "clip_1", opacity=185,
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,90),
        },},

    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },

    {
       delay = {time = 0.5,},
    },

    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },



    {action = {tag  = "zjue1",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.2,},},
    {bezier = {time = 0.4,to = cc.p(1200,200),
                                 control={cc.p(1600,200),cc.p(1400,200),}
    },},},
    },},},

    {action = {tag  = "long1",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,90),},},
    {bezier = {time = 0.4,to = cc.p(1000,300),
                                 control={cc.p(1600,200),cc.p(1300,300),}
    },},},
    },},},


    {
       delay = {time = 0.4,},
    },

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1200,200),    order     = 70,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.2,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-100,0),},},},},

    {   model = {
            tag  = "zjue2",     type  = DEF.FIGURE,
            pos= cc.p(1800,200),    order     = 70,
            file = "_lead_",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 1.5,opacity=185,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "long2",     type  = DEF.FIGURE,
            pos= cc.p(1600,300),    order     = 80,
            file = "effect_wg_kongmingquan",    animation = "bao",
            scaleX = 1, scaleY = 2,   parent = "clip_1", opacity=185,
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,90),
        },},
    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },

    {
       delay = {time = 0.5,},
    },
    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },
    {remove = { model = {"zjue1","long1", }, },},


    {action = {tag  = "zjue2",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.2,},},
    {bezier = {time = 0.5,to = cc.p(1100,200),
                                 control={cc.p(1600,200),cc.p(1400,200),}
    },},},
    },},},

    {action = {tag  = "long2",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,90),},},
    {bezier = {time = 0.5,to = cc.p(900,300),
                                 control={cc.p(1600,300),cc.p(1300,300),}
    },},},
    },},},



    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "zjue3",     type  = DEF.FIGURE,
            pos= cc.p(1800,200),    order     = 70,
            file = "_lead_",    animation = "pugong",
            scale = 0.2,   parent = "clip_1", speed = 1.5,opacity=185,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },
    {   model = {
            tag  = "long3",     type  = DEF.FIGURE,
            pos= cc.p(1600,300),    order     = 80,
            file = "effect_wg_kongmingquan",    animation = "bao",
            scaleX = 1, scaleY = 2,   parent = "clip_1", opacity=185,
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,90),
        },},
    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },
    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1100,200),    order     = 70,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.2,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.5,by = cc.p(-100,0),},},},},

    {
       delay = {time = 0.3,},
    },

    {
        sound = {file = "skill_kongmingquan.mp3",sync=false,},
    },

    {remove = { model = {"zjue2","long2", }, },},


    {action = {tag  = "zjue3",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.2,},},
    {bezier = {time = 0.6,to = cc.p(1000,200),
                                 control={cc.p(1600,200),cc.p(1400,200),}
    },},},
    },},},

    {action = {tag  = "long3",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,90),},},
    {bezier = {time = 0.6,to = cc.p(800,300),
                                 control={cc.p(1600,300),cc.p(1300,300),}
    },},},
    },},},




    {
       delay = {time = 0.5,},
    },
    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(1000,200),    order     = 70,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.2,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.6,by = cc.p(-100,0),},},},},

    {
       delay = {time = 0.2,},
    },


    {remove = { model = {"zjue3","long3", }, },},


    {
       delay = {time = 0.4,},
    },
    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(900,200),    order     = 70,
            file = "hero_ouyangke",    animation = "yun",
            scale = 0.2,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"cxfeng", }, },},
    {   model = {
            tag  = "cxfeng",     type  = DEF.FIGURE,
            pos= cc.p(300,150),    order     = 60,
            file = "hero_chenxuanfeng",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "cxfeng",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.3,to = cc.p(900,200),
                                 control={cc.p(300,150),cc.p(600,600),}
    },},},
    },},},

    {
       delay = {time = 0.2,},
    },

     {
         load = {tmpl = "move1",
             params = {"cxf","cxf.png",TR("陈玄风")},},
     },

     {
         load = {tmpl = "talk",
             params = {"cxf",TR("疯子，让你疯疯癫癫的，下次再这样我可不管你了！"),"5045.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"cxf"},},
    },



    {remove = { model = {"cxfeng", }, },},
    {   model = {
            tag  = "cxfeng",     type  = DEF.FIGURE,
            pos= cc.p(900,200),    order     = 60,
            file = "hero_chenxuanfeng",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "cxfeng",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.3,to = cc.p(300,200),
                                 control={cc.p(900,200),cc.p(600,600),}
    },},},
    },},},

    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.2,},},
    {bezier = {time = 0.3,to = cc.p(300,200),
                                 control={cc.p(900,200),cc.p(600,600),}
    },},},
    },},},

    {remove = { model = {"cxfeng","oyke", }, },},



	{
        music = {file = "backgroundmusic5.mp3",},
    },


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.4,
            size = cc.size(DEF.WIDTH, 0),},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.7","-1000","-200"},},
     },







     {
         load = {tmpl = "zm",
             params = {TR("在赶走欧阳克之后，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("你赶紧查看陆无双的伤势，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("但是，一切已经无法挽回……"),"700"},},
     },



    {delay = {time = 2.4,},},

    {remove = { model = { "800","750", "700", }, },},







    -- {remove = { model = {"lwshuang", }, },},
    -- {   model = {
    --         tag  = "lwshuang",     type  = DEF.FIGURE,
    --         pos= cc.p(830,350),    order     = 50,
    --         file = "hero_luwushuang",    animation = "yun",
    --         scale = 0.2,   parent = "clip_1", speed = 0,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,15),
    --     },},

    {remove = { model = {"zjue", }, },},

        {action = { tag  = "lwshuang",sync = false,what = {move = {
                   time = 0.01,to = cc.p(1400,0),},},},},
        {action = { tag  = "yupan",sync = false,what = {move = {
                   time = 0.01,by = cc.p(-280,-100),},},},},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1500,0),    order     = 20,
            file = "_lead_",    animation = "yun",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0, rotation3D=cc.vec3(0,0,0),
        },},


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.4,
            size = cc.size(DEF.WIDTH, 860),},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("陆姑娘！陆姑娘！你怎么样了？"),"1266.mp3"},},
     },


     {
         load = {tmpl = "move2",
             params = {"lws","lws.png",TR("陆无双")},},
     },
    {
        model = {
            tag   = "xue4",
            type  = DEF.PIC,
            scaleX = 0.36,scaleY = 0.35,
            pos   = cc.p(437, 662),
            order = 100,
            file  = "xue1.png",
            parent= "lws", opacity=135,
            rotation3D=cc.vec3(0,0,0),
        },
    },
     {
         load = {tmpl = "talk",
             params = {"lws",TR("傻蛋……你不是傻蛋？啊！快，我们快去——噗——！"),"1267.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("陆姑娘，你受的伤很重，让我先为你疗伤吧！"),"1268.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("没用的——我知道——我活不了多久了——求求你，救救傻——傻——杨——过——"),"1269.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("这——究竟是怎么回事——"),"1270.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("那些人——在找傻蛋——要——抓他——来威胁他师父——"),"1271.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("小龙女！？"),"1272.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("求你——救救他——告诉他——我——我——喜——喜欢——"),"1273.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"lws"},},
    },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("陆姑娘！这！为什么会这样，不应该这样的！啊——！！！！"),"1274.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },

       {remove = { model = {"text-board", }, },},


    {
       delay = {time = 0.2,},
    },

    {
        model = {
            tag       = "chuansong1",     type      = DEF.FIGURE,
            pos= cc.p(1530,336),     order     = 30,
            file      = "effect_ui_chuansongmen",         animation = "zeizhao",
            scaleX     = 3.2,   scaleY=2.4  ,    loop      = true, opacity=250,
            endRlease = false,         parent = "clip_1", speed=1,
        },},
    {
        model = {
            tag       = "chuansong11",     type      = DEF.FIGURE,
            pos= cc.p(1500,530),     order     = 35,
            file      = "effect_ui_chuansongmen",         animation = "chuansongmen",
            scaleX     = 1.6,   scaleY     = 1.2,       loop      = true,
            endRlease = false,         parent = "clip_1", speed=0.3,
        },},



    {
        sound = {file = "hero_chongsheng.mp3",sync=false,},
    },


    {action = {tag  = "zjue",sync = false,what ={ spawn={{move= {time = 0.5,by = cc.p(0,500),},},
    {scale = {to = 0.09,time = 0.8,},},{fadeout = {time = 0.8,},},},},},},
    {action = {tag  = "lwshuang",sync = true,what ={ spawn={{move= {time = 0.5,by = cc.p(0,500),},},
    {scale = {to = 0.09,time = 0.8,},},{fadeout = {time = 0.8,},},},},},},


    {action = {tag  = "yupan",sync = true,what ={ spawn={{move= {time = 0.5,by = cc.p(0,0),},},
    {scale = {to = 0,time = 0.5,},},{fadeout = {time = 0.5,},},},},},},

    {remove = { model = {"chuansong11", "chuansong1","yupan","zjue","lwshuang",}, },},


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.4,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
        model = {
            tag   = "map4",
            type  = DEF.PIC,
            scale = 1.5,
            pos   = cc.p(0, 200),
            order = -88,
            file  = "dw_20.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },



     {
         load = {tmpl = "zm",
             params = {TR("你和重伤的陆无双，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("被卷入神奇的空间中，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("事情似乎又有了转机……"),"700"},},
     },



    {delay = {time = 2.4,},},

    {remove = { model = { "800","750", "700", }, },},






     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","0","0"},},
     },

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(100,-180),    order     = 50,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-70,-250),    order     = 60,
            file = "hero_luwushuang",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,80),
        },},

    {   model = {
            tag  = "lcying",     type  = DEF.FIGURE,
            pos= cc.p(540,-100),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.4,
            size = cc.size(DEF.WIDTH, 860),},
    },

    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(100,-180),    order     = 50,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("这……这是什么地方？"),"50461.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("啊——陆姑娘，陆姑娘她怎么样了？"),"50462.mp3"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "lcying",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.15,},},
    {bezier = {time = 0.5,to = cc.p(250,-150),
                                 control={cc.p(540,-100),cc.p(360,300),}
    },},},
    },},},


     {
         load = {tmpl = "move2",
             params = {"jls","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"jls",TR("噢！陆姑娘？你对她——还真是不错呢？"),"5047.mp3"},},
     },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(100,-180),    order     = 50,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

     {
         load = {tmpl = "talk",
             params = {"zj",TR("你是？"),"5048.mp3"},},
     },
     {
         load = {tmpl = "talk1",
             params = {"jls",TR("在这里——可轮不到你来提问！"),"5049.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"jls",TR("我倒是有几个问题，你可要老老实实回答我！"),"5050.mp3"},},
     },
     {
         load = {tmpl = "talk",
             params = {"zj",TR("姑娘你说！"),"5051.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"jls",TR("哼哼！我漂亮吗？"),"5052.mp3"},},
     },






     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.9","3","-560","50"},},
     -- },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("呃——姑娘自然是十分的美丽！"),"5053.mp3"},},
     },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.9","0.8","-50","0"},},
     },
     {
         load = {tmpl = "talk",
             params = {"jls",TR("嘻嘻！那么你会喜欢上我吗？"),"5054.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("啊——那个——我与姑娘才——"),"5055.mp3"},},
     },
     {
         load = {tmpl = "talk1",
             params = {"jls",TR("还真是让人家不喜欢的答案呢！"),"5056.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"jls",TR("好啦！我累了，你可以退下啦！"),"5057.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("那个——陆姑娘她？"),"5058.mp3"},},
     },
     {
         load = {tmpl = "talk1",
             params = {"jls",TR("哼！陆姑娘，在这里——她死不了……也活不了。"),"5059.mp3"},},
     },
     {
         load = {tmpl = "talk0",
             params = {"jls",TR("只要你能找到方法，化解她体内的歹毒内功——她自然有救！"),"5060.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"jls",TR("不过下次再来的时候，你可要先想好怎么哄我开心，要知道——我一不高兴，可是谁都不搭理的！"),"5061.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","jls"},},
    },



    {remove = { model = {"lcying", }, },},
    {   model = {
            tag  = "lcying",     type  = DEF.FIGURE,
            pos= cc.p(250,-150),    order     = 40,
            file = "hero_yinsuojinling",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.7,},
    },



    {
        model = {
            tag       = "chuansong1",     type      = DEF.FIGURE,
            pos= cc.p(130,36),     order     = 30,
            file      = "effect_ui_chuansongmen",         animation = "zeizhao",
            scaleX     = 1.6,   scaleY=1.2  ,    loop      = true, opacity=0,
            endRlease = false,         parent = "clip_1", speed=1,
        },},
    {
        model = {
            tag       = "chuansong11",     type      = DEF.FIGURE, opacity=0,
            pos= cc.p(100,130),     order     = 35,
            file      = "effect_ui_chuansongmen",         animation = "chuansongmen",
            scaleX     = 0.8,   scaleY     = 0.6,       loop      = true,
            endRlease = false,         parent = "clip_1", speed=0.3,
        },},


    {action = {tag  = "chuansong11",sync = true,what ={ spawn={{move= {time = 0.5,by = cc.p(0,100),},},
    {fadein = {time = 0.5,},},},},},},

    {remove = { model = {"lcying", }, },},
    {   model = {
            tag  = "lcying",     type  = DEF.FIGURE,
            pos= cc.p(250,-150),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},


    {action = {tag  = "chuansong1",sync = true,what ={ spawn={{move= {time = 0.4,by = cc.p(0,0),},},
    {fadein = {time = 0.4,},},},},},},
    {
        sound = {file = "hero_chongsheng.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = true,what ={ spawn={{move= {time = 0.3,by = cc.p(0,360),},},
    {scale = {to = 0.08,time = 0.3,},},{fadeout = {time = 0.4,},},},},},},


    {action = {tag  = "chuansong1",sync = true,what ={ spawn={{move= {time = 0.2,by = cc.p(0,0),},},
    {fadeout = {time = 0.2,},},},},},},
    {action = {tag  = "chuansong11",sync = true,what ={ spawn={{move= {time = 0.2,by = cc.p(0,0),},},
    {scale = {to = 0,time = 0.2,},},{fadeout = {time = 0.2,},},},},},},


     {
         load = {tmpl = "move2",
             params = {"jls","jls.png",TR("粉衣美女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"jls",TR("这张让人又怜又爱的脸蛋——还真是让人讨厌呢！"),"5062.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"jls"},},
    },

    {remove = { model = {"lcying", }, },},
    {   model = {
            tag  = "lcying",     type  = DEF.FIGURE,
            pos= cc.p(250,-150),    order     = 40,
            file = "hero_yinsuojinling",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.2, rotation3D=cc.vec3(0,180,0),
        },},


    {   model = {
            tag  = "yiji1",     type  = DEF.FIGURE,
            pos= cc.p(0,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,-40),
        },},




    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "yiji2",     type  = DEF.FIGURE,
            pos= cc.p(40,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1.2, rotation3D=cc.vec3(0,180,-40),
        },},


    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "yiji3",     type  = DEF.FIGURE,
            pos= cc.p(-40,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1.1, rotation3D=cc.vec3(0,180,-40),
        },},
    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "yiji4",     type  = DEF.FIGURE,
            pos= cc.p(60,-240),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.9, rotation3D=cc.vec3(0,180,-40),
        },},

    {
        sound = {file = "hero_gongsunlve_pugong.mp3",sync=false,},
    },
    {
       delay = {time = 0.1,},
    },
    {remove = { model = {"lcying", }, },},
    {   model = {
            tag  = "lcying",     type  = DEF.FIGURE,
            pos= cc.p(250,-150),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},
    {
       delay = {time = 0.2,},
    },

    {
        sound = {file = "hero_gongsunlve_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "yiji11",     type  = DEF.FIGURE,
            pos= cc.p(0,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.12,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,-40),
        },},
    {
       delay = {time = 0.3,},
    },




    {   model = {
            tag  = "yiji21",     type  = DEF.FIGURE,
            pos= cc.p(20,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.12,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1.2, rotation3D=cc.vec3(0,180,-40),
        },},
    {
       delay = {time = 0.3,},
    },

    {
        sound = {file = "hero_gongsunlve_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "yiji31",     type  = DEF.FIGURE,
            pos= cc.p(-20,-250),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.12,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1.1, rotation3D=cc.vec3(0,180,-40),
        },},

    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "yiji41",     type  = DEF.FIGURE,
            pos= cc.p(40,-240),    order     = 70,
            file = "effect_gongsunlve_pugong",    animation = "pugong",
            scale = 0.12,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.9, rotation3D=cc.vec3(0,180,-40),
        },},

    {
       delay = {time = 3.6,},
    },

    {action = {tag  = "lwshuang",sync = true,what ={ spawn={
    {move = {time = 1.2,by = cc.p(0,180),},},
    },},},},

    {
       delay = {time = 0.3,},
    },

    {action = {tag  = "lwshuang",sync = true,what ={ spawn={
    {move = {time = 0.9,by = cc.p(40,-40),},},
    {rotate= {time = 1.2,to  = cc.vec3(0,180,0),},},
    },},},},

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-30,-130),    order     = 60,
            file = "hero_luwushuang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "lwshuang",sync = true,what ={ spawn={
    {move = {time = 0.6,by = cc.p(0,-40),},},
    },},},},

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-30,-170),    order     = 60,
            file = "hero_luwushuang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"lws","lws.png",TR("陆无双")},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("奴婢陆无双见过主人，主人就仿佛是天上最美丽的星辰，璀璨夺目，美艳无双——"),"5063.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"jls","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"jls",TR("哈哈哈！不是仿佛——而是本身就是，看在你这么会说话的份上，我就许你贴身伺候我吧！"),"5064.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("能伺候世间最美丽的主人是奴婢的荣幸！"),"5065.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"jls",TR("哈哈哈！你这样，我很喜欢哦！"),"5066.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"lws","jls"},},
    },

    {
       delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
