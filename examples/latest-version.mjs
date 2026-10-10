// Get the latest version and support status of any product.
// Node 18+ (built-in fetch) or any modern browser; the API allows cross-origin requests.
//   node latest-version.mjs php nodejs ubuntu

async function latest(product) {
  const res = await fetch(`https://latestat.com/api/${product}.json`);
  if (!res.ok) throw new Error(`${product}: HTTP ${res.status}`);
  const data = await res.json();
  const newest = data.cycles.find((c) => c.cycle === data.latest?.cycle);
  return {
    product: data.name,
    latest: data.latest?.version ?? null,
    released: data.latest?.date ?? null,
    endOfLife: newest?.eol ?? null,
    page: data.url,
  };
}

const products = process.argv.slice(2);
for (const p of products.length ? products : ['php', 'nodejs', 'ubuntu']) {
  console.log(await latest(p));
}
