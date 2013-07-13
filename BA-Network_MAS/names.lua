local names = {}

names.db = {
  "マッテオ",
  "パチョウ",
  "ソンノ",
  "ちゃっとい",
  "おそし",
  "みうらの",
  "ばかだい",
  "いしこわ",
  "ちちもと",
  "むたんで",
  "むかに",
  "おおわら",
  "がま",
  "こねこ",
  "あとずみ",
  "おおたんたん",
  "ほのし",
  "ほりうんち",
  "さいこう",
  "さぼる",
  "あさから",
  "はうらんぼう",
  "天王星"
}

names.buffer = {}
names.counter = 0

function shuffled(tab)
  local n, order, res = #tab, {}, {}
 
  for i=1,n do order[i] = { rnd = math.random(), idx = i } end
  table.sort(order, function(a,b) return a.rnd < b.rnd end)
  for i=1,n do res[i] = tab[order[i].idx] end
  return res
end

function names.next()
  if #names.buffer == 0 then
    names.buffer = shuffled(names.db)
    names.counter = names.counter + 1
  end
  if names.counter > 1 then
    return table.remove(names.buffer).."("..names.counter..")"
  else
    return table.remove(names.buffer)
  end
end

return names