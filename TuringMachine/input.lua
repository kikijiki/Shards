-- 回文を受理するチューリングマシン

local tm = {
  Q = {"q0", "q1", "q2", "q3", "q4", "q5", "q6", "q7"},
  q0 = "q0",
  A = {"a", "b"},
  Qa = {"q5"},
  Qf = {"q6"},
  transitions = {
    "q0,a,q1,#,R",
    "q0,b,q2,#,R",
    "q0,#,q5,#,L",
    
    "q1,a,q1,a,R",
    "q1,b,q1,b,R",
    "q1,#,q3,#,L",
    
    "q2,a,q2,a,R",
    "q2,b,q2,b,R",
    "q2,#,q4,#,L",
    
    "q3,a,q7,#,L",
    "q3,b,q6,b,L",
    "q3,#,q5,#,L",

    "q4,a,q6,a,L",
    "q4,b,q7,#,L",
    "q4,#,q5,#,L",
    
    "q7,a,q7,a,L",
    "q7,b,q7,b,L",
    "q7,#,q0,#,R",
  },
  empty = "#",
  -- アルファベットが全部１文字ずつではなければ、separatorを追加する
  -- es. input = {tape = "a,b,c", separator = ","}
  input = {tape = "abababbabbababa"},
}

return tm