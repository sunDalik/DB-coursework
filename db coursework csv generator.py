import csv, faker, random, datetime as dt, dateutil.relativedelta as rd

fake = faker.Faker()

genders = ['male', 'female', 'other']
transport_type = ['land', 'air']

# Btw такое уточнение - подразумевается что схема новая абсолютно и все id начинаются с единицы
employees_data = []
transport_data = []
weaponry_data = []
district_houses_data = []
prawns_data = []
scientist_profiles_data = []
security_profiles_data = []
management_profiles_data = []
arms_deals_data = []
experiments_data = []
weapons_in_arms_deals_data = []
prawns_in_experiments_data = []

employees_data.append(['name', 'date_of_birth', 'date_of_death', 'date_of_employment', 'gender', 'salary'])
start_date = dt.date(1920, 1, 1)
for x in range(0, 210000):
    days_passed = random.randint(0, (dt.date.today() + rd.relativedelta(years=-18) - start_date).days)
    birth_date = start_date + dt.timedelta(days=days_passed)
    days_passed = random.randint(0, (dt.date.today() + rd.relativedelta(years=-18) - birth_date).days)
    employment_date = birth_date + dt.timedelta(days=days_passed) + rd.relativedelta(years=+18)
    if random.randint(0, 100) <= 20:
        days_passed = random.randint(0, (dt.date.today() - employment_date).days)
        death_date = employment_date + dt.timedelta(days=days_passed)
    else:
        death_date = ''
    employees_data.append([fake.name(), birth_date, death_date, employment_date, random.choice(genders),
                           random.randint(1, 1000000)])

with open('C:/Users/Далик/Desktop/employees.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(employees_data)
print('СОтрудники записаны')

transport_data.append(['type', 'name', 'availability', 'required_access_lvl'])
for x in range(0, 200000):
    n = random.randint(2, 4)
    transport_data.append([random.choice(transport_type),
                           ''.join(random.choice('abcdefghijklmnopqrstuvwxyz') for _ in range(n)) + '-' + str(
                               random.randint(1, 99)),
                           True, random.randint(0, 5)])

with open('C:/Users/Далик/Desktop/transport.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(transport_data)
print('Транспорт записан')

weapon_types = ['rifle', 'handgun', 'shotgun', 'alien']
rifle_bullets = ['22 Long', '6mm BR', '270 Win', '7mm Dakota', '30 Rem', '300 Norma', '50 Beowulf', '416 Taylor']
handgun_bullets = ['22 LR', '38 Long Colt', '10mm Auto', '44 Russian', '45 GAP', '480 Ruger', '50 AE', '500 Wyoming']
shotgun_bullets = ['32 Gauge', '24 Gauge', '8 Gauge', 'Birdshot', 'Slug', '54 Caliber', '45 Caliber']
alien_bullets = ['energy']
weaponry_data.append(['name', 'type', 'ammo_type', 'quantity', 'required_access_lvl'])
for x in range(0, 120000):
    n = random.randint(2, 4)
    weapon_type = random.choice(weapon_types)
    if weapon_type == 'rifle':
        bullet_type = random.choice(rifle_bullets)
    elif weapon_type == 'handgun':
        bullet_type = random.choice(handgun_bullets)
    elif weapon_type == 'shotgun':
        bullet_type = random.choice(shotgun_bullets)
    elif weapon_type == 'alien':
        bullet_type = random.choice(alien_bullets)
    else:
        bullet_type = 'none'
    weaponry_data.append([''.join(random.choice('abcdefghijklmnopqrstuvwxyz') for _ in range(n)) + '-' + str(
        random.randint(1, 99)), weapon_type, bullet_type, random.randint(0, 999), random.randint(0, 5)])

with open('C:/Users/Далик/Desktop/weaponry.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(weaponry_data)
print('Оружия записаны')

row = 1
column = 1
start_date = dt.date(2009, 1, 1)
for x in range(0, 70000):
    days_passed = random.randint(0, (dt.date.today() - start_date).days)
    district_houses_data.append([row, column, start_date + dt.timedelta(days=days_passed)])
    column += 1
    if column > 700:
        row += 1
        column = 1

random.shuffle(district_houses_data)
district_houses_data.insert(0, ['shelter_row', 'shelter_column', 'construction_date'])
with open('C:/Users/Далик/Desktop/district_houses.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(district_houses_data)
print('Домики записаны')

start_date = dt.date(1970, 1, 1)
activity_type = ['trader', 'bandit', 'hunter', 'mechanic', 'loafer', 'worker']
reason_of_death = ['killed by human', 'killed by prawn', 'accident', 'natural death', 'disease']
for x in range(0, 140000):
    n = x
    days_passed = random.randint(0, (dt.date.today() - start_date).days)
    birth_date = start_date + dt.timedelta(days=days_passed)
    if random.randint(0, 100) <= 50:
        days_passed = random.randint(0, (dt.date.today() - birth_date).days)
        death_date = birth_date + dt.timedelta(days=days_passed)
        reason = random.choice(reason_of_death)
    else:
        death_date = ''
        reason = ''

    if n > 69999:
        n -= 70000
    prawns_data.append([n + 1, fake.name(), random.choice(activity_type), birth_date, death_date, reason])

random.shuffle(prawns_data)
prawns_data.insert(0, ['house_id', 'name', 'activity_type', 'date_of_birth', 'date_of_death', 'reason_of_death'])
with open('C:/Users/Далик/Desktop/prawns.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(prawns_data)
print('Моллюски записаны')

employees_ids = [x for x in range(1, 210001)]
random.shuffle(employees_ids)
scientist_ids = employees_ids[:70000]
security_ids = employees_ids[70000:140000]
management_ids = employees_ids[140000:]

scientist_positions = ['biologist', 'engineer', 'programmer']
for x in range(0, 70000):
    scientist_profiles_data.append([scientist_ids[x], 0, 0, random.randint(0, 10)])
print('Ученые загрузка 1/2')
for x in range(0, 70000):
    emp_id = scientist_profiles_data[x][0]
    sup_lvl = scientist_profiles_data[x][3]
    if sup_lvl < 10:
        while True:
            supervisor = random.choice(scientist_profiles_data)
            if supervisor[3] > sup_lvl:
                sup_id = supervisor[0]
                break
    else:
        sup_id = ''
    scientist_profiles_data[x] = [emp_id, sup_id, random.choice(scientist_positions), sup_lvl]
scientist_profiles_data.insert(0, ['employee_id', 'supervisor_id', 'position', 'supervising_level'])
with open('C:/Users/Далик/Desktop/scientist_profiles.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(scientist_profiles_data)
print('Ученые записаны')

security_positions = ['soldier', 'mnu guard', 'district guard']
for x in range(0, 70000):
    security_profiles_data.append([security_ids[x], 0, 0, 0, 0, 0, random.randint(0, 10)])
print('Секурити загрузка 1/2')
for x in range(0, 70000):
    emp_id = security_profiles_data[x][0]
    sup_lvl = security_profiles_data[x][6]
    if sup_lvl < 10:
        while True:
            supervisor = random.choice(security_profiles_data)
            if supervisor[6] > sup_lvl:
                sup_id = supervisor[0]
                break
    else:
        sup_id = ''
    access_level = random.randint(0, 5)
    if sup_lvl >= 8 and random.randint(0, 100) <= 30:
        if access_level < 2:
            access_level += 1
        while True:
            transport_id = random.randint(1, 200000)
            transport = transport_data[transport_id]
            if transport[2] and access_level >= int(transport[3]):
                transport_data[transport_id][2] = False
                break
    else:
        transport_id = ''
    if sup_lvl >= 8 and access_level < 2:
        access_level += 1
    while True:
        weapon_id = random.randint(1, 120000)
        weapon = weaponry_data[weapon_id]
        if int(weapon[3]) > 0 and access_level >= int(weapon[4]):
            weaponry_data[weapon_id][3] -= 1
            break
    security_profiles_data[x] = [emp_id, sup_id, transport_id, weapon_id,
                                 random.choice(security_positions), access_level, sup_lvl]
security_profiles_data.insert(0,
                              ['employee_id', 'supervisor_id', 'transport_id', 'weapon_id', 'position', 'access_level',
                               'supervising_level'])
with open('C:/Users/Далик/Desktop/security_profiles.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(security_profiles_data)
print('Секурити записаны')

for x in range(0, 70000):
    n = random.randint(1, 100)
    if n > 90:
        pos = 'administrator'
        sup_lvl = random.randint(8, 10)
    elif n > 50:
        pos = 'manager'
        sup_lvl = random.randint(2, 7)
    else:
        pos = 'clerk'
        sup_lvl = random.randint(0, 1)
    management_profiles_data.append([management_ids[x], 0, pos, 0, sup_lvl])
print('менеджеры загрузка 1/2')
for x in range(0, 70000):
    emp_id = management_profiles_data[x][0]
    pos = management_profiles_data[x][2]
    sup_lvl = management_profiles_data[x][4]
    if sup_lvl < 10:
        while True:
            supervisor = random.choice(management_profiles_data)
            if supervisor[4] > sup_lvl:
                sup_id = supervisor[0]
                break
    else:
        sup_id = ''
    management_profiles_data[x] = [emp_id, sup_id, pos, random.randint(0, 5), sup_lvl]
management_profiles_data.insert(0, ['employee_id', 'supervisor_id', 'position', 'access_level', 'supervising_level'])
with open('C:/Users/Далик/Desktop/management_profiles.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(management_profiles_data)
print('Менеджеры записаны')

arms_deals_data.append(['dealer_id', 'date', 'client', 'earn'])
for x in range(0, 70000):
    dealer_id = random.randint(1, 70000)
    true_dealer_id = management_profiles_data[dealer_id][0]
    dealer = employees_data[true_dealer_id]
    if dealer[2] == '':
        days_passed = random.randint(0, (dt.date.today() - dealer[3]).days)
        deal_date = dealer[3] + dt.timedelta(days=days_passed)
    else:
        days_passed = random.randint(0, (dealer[2] - dealer[3]).days)
        deal_date = dealer[3] + dt.timedelta(days=days_passed)
    arms_deals_data.append([true_dealer_id, deal_date, fake.name(), random.randint(1, 100000000)])
with open('C:/Users/Далик/Desktop/arms_deals.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(arms_deals_data)
print('Сделки записаны')

results = ['success', 'fail']
experiments_data.append(['examinator_id', 'date', 'experiment_name', 'results'])
for x in range(0, 70000):
    examinator_id = random.randint(1, 70000)
    true_examinator_id = scientist_profiles_data[examinator_id][0]
    examinator = employees_data[true_examinator_id]
    if examinator[2] == '':
        days_passed = random.randint(0, (dt.date.today() - examinator[3]).days)
        examine_date = examinator[3] + dt.timedelta(days=days_passed)
    else:
        days_passed = random.randint(0, (examinator[2] - examinator[3]).days)
        examine_date = examinator[3] + dt.timedelta(days=days_passed)
    experiments_data.append([true_examinator_id, examine_date,
                             ''.join(random.choice('abcdefghijklmnopqrstuvwxyz') for _ in range(2)) + '-' + str(
                                 random.randint(1, 99999999)), random.choice(results)])
with open('C:/Users/Далик/Desktop/experiments.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(experiments_data)
print('Эксперименты записаны')

prawns_in_experiments_data.append(['prawn_id', 'experiment_id'])
for x in range(0, 20000):
    prawns_in_experiments_data.append([random.randint(1, 140000), random.randint(1, 70000)])
with open('C:/Users/Далик/Desktop/prawns_in_experiments.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(prawns_in_experiments_data)
print('ассоциация 2 записана')

weapons_in_arms_deals_data.append(['weapon_id', 'deal_id'])
for x in range(0, 20000):
    deal = random.randint(1, 70000)
    dealer_id = arms_deals_data[deal][0]
    for n in range(1, 70001):
        if management_profiles_data[n][0] == dealer_id:
            dealer_id_in_manag = n
            break
    while True:
        weapon = random.randint(1, 120000)
        if int(management_profiles_data[n][3]) >= int(weaponry_data[weapon][4]) and int(weaponry_data[weapon][3]) > 0:
            weaponry_data[weapon][3] -= 1
            break
    weapons_in_arms_deals_data.append([weapon, deal])
with open('C:/Users/Далик/Desktop/weapons_in_arms_deals.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(weapons_in_arms_deals_data)
print('ассоциация 1 записана')
