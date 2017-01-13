from random import randrange

it = []

for i in range(0, 2048):
  s = bin(randrange(2100000000))
  sli = s[2:]
  sliz = sli.zfill(32)
  it.append(sliz)

for item in it:
  print(item)
