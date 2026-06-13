/**
 * seed_data.js — fills realistic demo data for all registered users
 * Uses Firestore REST API (no service account needed)
 */
const https = require('https');

const PROJECT  = 'adstick-90329';
const API_KEY  = 'AIzaSyCM6rwvSsXyK6fQAcHoEwTrlN9_yXZFvmk';
const RTDB_URL = 'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app';
const BASE     = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

// ── Helpers ─────────────────────────────────────────────────────────
function req(method, url, body) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const opts = {
      hostname: parsed.hostname,
      path:     parsed.pathname + parsed.search,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    const r = https.request(opts, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { resolve(data); }
      });
    });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

const fsUrl  = (col, id = '')  => `${BASE}/${col}${id ? '/' + id : ''}?key=${API_KEY}`;
const rtdbUrl = path           => `${RTDB_URL}/${path}.json`;

// Firestore field encoders
const str  = v  => ({ stringValue:   String(v) });
const num  = v  => ({ doubleValue:   Number(v) });
const int_ = v  => ({ integerValue:  String(Math.round(v)) });
const bool = v  => ({ booleanValue:  Boolean(v) });
const ts   = v  => ({ timestampValue: v instanceof Date ? v.toISOString() : v });
const nul  = () => ({ nullValue: 'NULL_VALUE' });

async function fsWrite(col, id, fields, mask) {
  const url = mask
    ? `${BASE}/${col}/${id}?key=${API_KEY}&${mask.map(f => `updateMask.fieldPaths=${f}`).join('&')}`
    : `${BASE}/${col}/${id}?key=${API_KEY}`;
  const res = await req('PATCH', url, { fields });
  if (res.error) throw new Error(`Firestore PATCH ${col}/${id}: ${JSON.stringify(res.error)}`);
  return res;
}

async function fsCreate(col, fields) {
  const url = `${BASE}/${col}?key=${API_KEY}`;
  const res = await req('POST', url, { fields });
  if (res.error) throw new Error(`Firestore POST ${col}: ${JSON.stringify(res.error)}`);
  return res.name.split('/').pop(); // returns document id
}

async function rtdbWrite(path, data) {
  const url = rtdbUrl(path);
  const res = await req('PUT', url, data);
  return res;
}

function rand(min, max) { return Math.random() * (max - min) + min; }
function randInt(min, max) { return Math.floor(rand(min, max + 1)); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function daysAgo(n) { const d = new Date(); d.setDate(d.getDate() - n); return d; }

// ── Saudi plate format: 3 letters + 4 digits ────────────────────────
function saudiPlate() {
  const letters = 'ABCDEFGHJKLMNPRSTUVXYZ';
  const l = Array.from({length: 3}, () => letters[randInt(0, letters.length - 1)]).join('');
  const n = String(randInt(1000, 9999));
  return `${l} ${n}`;
}

// Saudi mobile
function saudiPhone() { return `+9665${randInt(10000000, 99999999)}`; }

// ── Main ─────────────────────────────────────────────────────────────
async function main() {
  console.log('🌱  AdStick seed script starting…\n');

  // ── 1. Driver: louai alhaj (4XMbAL9A1ZRDOyLDzW2AfGTQMNs2) ──────────
  const DRIVER_UID = '4XMbAL9A1ZRDOyLDzW2AfGTQMNs2';
  const plate      = saudiPlate();
  const totalKm    = rand(1200, 3400);
  const totalEarn  = totalKm * 1.0;
  const withdrawn  = rand(200, 600);
  const wallet     = totalEarn - withdrawn;
  const streak     = randInt(3, 14);
  const quality    = rand(78, 95);

  console.log(`🚗 Seeding driver  ${DRIVER_UID}  plate=${plate}`);
  await fsWrite('users', DRIVER_UID, {
    name:            str('Louai Al-Hajj'),
    phone:           str(saudiPhone()),
    vehicleId:       str(plate),
    tier:            str('gold'),
    totalKm:         num(totalKm),
    totalEarnings:   num(totalEarn),
    totalWithdrawn:  num(withdrawn),
    walletBalance:   num(wallet),
    streakDays:      int_(streak),
    qualityScore:    num(quality),
    status:          str('active'),
    isActive:        bool(false),
    referralCode:    str('LOUAI2026'),
    role:            str('driver'),
    createdAt:       ts(daysAgo(45)),
    lastDriveDate:   ts(daysAgo(0)),
    _seedTest:       nul(),   // remove test field
  });

  // Earnings subcollection — last 21 days
  console.log('   📅 Writing 21 days of earnings…');
  for (let i = 0; i < 21; i++) {
    const d = daysAgo(i);
    const key = `${d.getFullYear()}${String(d.getMonth()+1).padStart(2,'0')}${String(d.getDate()).padStart(2,'0')}`;
    const km   = rand(8, 45);
    const earn = km * 1.0;
    await fsWrite(`earnings/${DRIVER_UID}/daily`, key, {
      date:       str(key),
      kmDriven:   num(km),
      earnings:   num(earn),
      durationMinutes: int_(km * 2.5),
      avgSpeedKmh:     num(rand(28, 55)),
      createdAt:  ts(d),
    });
  }

  // RTDB — today's live snapshot (parked)
  console.log('   📡 Writing RTDB driver node…');
  const todayKm = rand(12, 38);
  await rtdbWrite(`drivers/${DRIVER_UID}`, {
    name:              'Louai Al-Hajj',
    vehicleId:         plate,
    isActive:          false,
    stoppedAt:         Date.now() - 1000 * 60 * randInt(10, 90),
    lastSeen:          Date.now() - 1000 * 60 * randInt(10, 90),
    location: {
      lat:      24.7136 + (Math.random() - 0.5) * 0.08,
      lng:      46.6753 + (Math.random() - 0.5) * 0.08,
      speed:    '0',
      heading:  String(randInt(0, 359)),
      accuracy: '5',
      timestamp: Date.now() - 1000 * 60 * 12,
    },
    todayStats: {
      distanceKm:      todayKm.toFixed(2),
      durationMinutes: String(Math.round(todayKm * 2.5)),
      avgSpeedKmh:     String(rand(30, 52).toFixed(1)),
    },
  });

  // Leaderboard entry
  const monthKey = `${new Date().getFullYear()}${String(new Date().getMonth()+1).padStart(2,'0')}`;
  await fsWrite(`leaderboard/${monthKey}/entries`, DRIVER_UID, {
    kmThisMonth:       num(rand(180, 450)),
    earningsThisMonth: num(rand(180, 450)),
    lastUpdated:       ts(new Date()),
  });

  // Payout request
  console.log('   💸 Writing payout request…');
  await fsCreate('payouts', {
    driverId:    str(DRIVER_UID),
    driverName:  str('Louai Al-Hajj'),
    amount:      num(250),
    status:      str('pending'),
    requestedAt: ts(daysAgo(2)),
    processedAt: nul(),
    note:        nul(),
  });

  // ── 2. Advertiser: louai / lolo12 (Yd7RyU0McON7xs3Hl9O8) ───────────
  const ADV_UID = 'Yd7RyU0McON7xs3Hl9O8';
  const companies = [
    { company: 'AlNoor Trading Co.', contact: 'Louai Al-Noor' },
  ];
  const { company, contact } = companies[0];

  console.log(`\n📢 Seeding advertiser ${ADV_UID}  company=${company}`);
  await fsWrite('users', ADV_UID, {
    name:        str(contact),
    companyName: str(company),
    email:       str('lolo12@gmail.com'),
    phone:       str(saudiPhone()),
    role:        str('advertiser'),
    totalBudget: num(15000),
    totalSpent:  num(3820),
    activeAds:   int_(2),
    createdAt:   ts(daysAgo(40)),
    _seedTest:   nul(),
  });

  // ── 3. Campaigns ─────────────────────────────────────────────────────
  const campaignDefs = [
    {
      name:              'Summer Riyadh Drive',
      status:            'active',
      city:              'Riyadh',
      totalBudget:       8000,
      spentBudget:       2140,
      actualImpressions: 29960,
      targetImpressions: 80000,
      activeCars:        3,
      ratePerKm:         1.0,
      daysAgoCreated:    28,
    },
    {
      name:              'Brand Awareness — Jeddah Q3',
      status:            'active',
      city:              'Jeddah',
      totalBudget:       5000,
      spentBudget:       1680,
      actualImpressions: 23520,
      targetImpressions: 50000,
      activeCars:        2,
      ratePerKm:         1.2,
      daysAgoCreated:    15,
    },
    {
      name:              'Ramadan Special Campaign',
      status:            'completed',
      city:              'Riyadh',
      totalBudget:       3000,
      spentBudget:       3000,
      actualImpressions: 42000,
      targetImpressions: 40000,
      activeCars:        0,
      ratePerKm:         1.0,
      daysAgoCreated:    60,
    },
  ];

  const campIds = [];
  for (const c of campaignDefs) {
    console.log(`   📣 Campaign: "${c.name}" [${c.status}]`);
    const id = await fsCreate('campaigns', {
      name:              str(c.name),
      advertiserId:      str(ADV_UID),
      advertiserName:    str(company),
      status:            str(c.status),
      city:              str(c.city),
      totalBudget:       num(c.totalBudget),
      spentBudget:       num(c.spentBudget),
      actualImpressions: int_(c.actualImpressions),
      targetImpressions: int_(c.targetImpressions),
      activeCars:        int_(c.activeCars),
      ratePerKm:         num(c.ratePerKm),
      startDate:         ts(daysAgo(c.daysAgoCreated)),
      endDate:           ts(daysAgo(-30)),
      createdAt:         ts(daysAgo(c.daysAgoCreated)),
      lastActivityAt:    ts(daysAgo(randInt(0, 3))),
    });
    campIds.push(id);

    // Daily stats subcollection (last 14 days)
    for (let i = 0; i < 14 && i < c.daysAgoCreated; i++) {
      const d = daysAgo(i);
      const key = `${d.getFullYear()}${String(d.getMonth()+1).padStart(2,'0')}${String(d.getDate()).padStart(2,'0')}`;
      const dayKm   = rand(10, 40);
      const dayImp  = Math.round(dayKm * 14);
      const daySpend = dayKm * c.ratePerKm;
      await fsWrite(`campaigns/${id}/stats`, key, {
        date:        str(key),
        kmCovered:   num(dayKm),
        impressions: int_(dayImp),
        spend:       num(daySpend),
        activeCars:  int_(randInt(1, c.activeCars + 2)),
      });
    }
  }

  // Assign driver to first active campaign
  const firstActiveCamp = campIds[0];
  console.log(`\n   🔗 Linking driver → campaign ${firstActiveCamp}`);
  await fsWrite('users', DRIVER_UID, {
    currentCampaignId: str(firstActiveCamp),
  }, ['currentCampaignId']);

  // ── 4. Invoice for completed campaign ────────────────────────────────
  console.log('\n   🧾 Writing invoice for completed campaign…');
  await fsCreate('invoices', {
    advertiserId:        str(ADV_UID),
    advertiserName:      str(company),
    campaignId:          str(campIds[2]),
    campaignName:        str(campaignDefs[2].name),
    amount:              num(campaignDefs[2].spentBudget),
    platformFee:         num(campaignDefs[2].spentBudget * 0.30),
    status:              str('paid'),
    issuedDate:          ts(daysAgo(30)),
    dueDate:             ts(daysAgo(0)),
    paidDate:            ts(daysAgo(15)),
    impressionsDelivered: int_(campaignDefs[2].actualImpressions),
    kmCovered:           num(campaignDefs[2].spentBudget / campaignDefs[2].ratePerKm),
  });

  // ── 5. Platform stats summary ─────────────────────────────────────────
  console.log('\n📊 Updating platform_stats/summary…');
  const totalDriverKm = totalKm + rand(500, 900);
  const platformRev   = totalDriverKm * 0.30;

  await fsWrite('platform_stats', 'summary', {
    totalDrivers:        int_(1),
    activeDrivers:       int_(0),
    totalKmToday:        num(todayKm),
    totalKmAllTime:      num(totalDriverKm),
    revenueToday:        num(todayKm * 0.30),
    revenueThisMonth:    num(platformRev * 0.2),
    revenueAllTime:      num(platformRev),
    activeCampaigns:     int_(2),
    totalCampaigns:      int_(3),
    totalImpressionsToday: int_(Math.round(todayKm * 14)),
    avgQualityScore:     num(quality),
    fraudAlertsOpen:     int_(0),
    pendingPayouts:      int_(1),
    pendingPayoutsAmount: num(250),
    lastUpdated:         ts(new Date()),
  });

  // ── 6. Quality score ─────────────────────────────────────────────────
  console.log('⭐ Writing quality score…');
  await fsWrite('quality_scores', DRIVER_UID, {
    driverName:          str('Louai Al-Hajj'),
    score:               num(quality),
    gpsConsistency:      num(rand(80, 95)),
    activeHoursRatio:    num(rand(70, 90)),
    campaignCompliance:  num(90),
    customerRating:      num(85),
    computedTier:        str('gold'),
    lastComputed:        ts(new Date()),
  });

  console.log('\n✅  All done! Summary:');
  console.log(`   Driver  : Louai Al-Hajj  |  plate=${plate}  |  ${totalKm.toFixed(0)} km  |  SAR ${wallet.toFixed(0)} wallet`);
  console.log(`   Advertiser: ${company}`);
  console.log(`   Campaigns : ${campIds.length}  (2 active, 1 completed)`);
  console.log(`   Invoice   : SAR 3000 paid`);
  console.log(`   Payout req: SAR 250 pending`);
}

main().catch(e => { console.error('❌', e.message); process.exit(1); });
