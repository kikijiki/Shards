--εはnilで入力する
--4月18日の授業のオートマトンです
local data = {}
data = {
  Q = {"q1", "q2", "q3"},
  q0 = "q0",
  A = {"0", "1", "2"},
  Qa = {"q2"},

  transitions = {
    q0 = {{"0", "q0"}, {nil, "q1"}},
    q1 = {{"1", "q1"}, {nil, "q2"}},
    q2 = {{"2", "q2"}},
  }
}
return data