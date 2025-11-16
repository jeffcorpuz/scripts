const API_BASE = 'http://localhost:8000';

async function classifyImage(file){
  const formData = new FormData();
  formData.append('file', file);
  const res = await fetch(`${API_BASE}/classify`, {method:'POST', body:formData});
  if(!res.ok) throw new Error('Classify failed');
  return res.json();
}

async function fetchSpecies(name){
  const res = await fetch(`${API_BASE}/species/${encodeURIComponent(name)}`);
  if(!res.ok) throw new Error('Species fetch failed');
  return res.json();
}

async function createSighting(payload){
  const res = await fetch(`${API_BASE}/sightings`, {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)});
  if(!res.ok) throw new Error('Sighting create failed');
  return res.json();
}

async function listSightings(){
  const res = await fetch(`${API_BASE}/sightings`);
  if(!res.ok) throw new Error('List sightings failed');
  return res.json();
}

function renderClassifications(data){
  const box = document.getElementById('classifyResults');
  box.innerHTML='';
  data.results.forEach(r=>{
    const div=document.createElement('div');
    div.className='result';
    div.textContent=`${r.species_name} (${(r.score*100).toFixed(1)}%)`;
    div.addEventListener('click', async ()=>{
      const info = await fetchSpecies(r.species_name);
      renderSpecies(info);
    });
    box.appendChild(div);
  });
  if(data.results.length){
    document.getElementById('speciesSection').hidden=false;
    document.getElementById('sightingSection').hidden=false;
    document.getElementById('speciesGuess').value=data.results[0].species_name;
  }
}

function renderSpecies(info){
  const box=document.getElementById('speciesInfo');
  box.innerHTML='';
  const h=document.createElement('h3');
  h.textContent=info.common_name || info.scientific_name || info.id;
  box.appendChild(h);
  if(info.scientific_name){
    const sci=document.createElement('p');
    sci.textContent=`Scientific: ${info.scientific_name}`;
    box.appendChild(sci);
  }
  if(info.conservation_status){
    const cs=document.createElement('p');
    cs.textContent=`Status: ${info.conservation_status}`;
    box.appendChild(cs);
  }
  if(info.wiki_summary){
    const sum=document.createElement('p');
    sum.textContent=info.wiki_summary.slice(0,400)+(info.wiki_summary.length>400?'…':'');
    box.appendChild(sum);
  }
  (info.images||[]).forEach(url=>{
    const img=document.createElement('img');
    img.src=url;
    box.appendChild(img);
  });
}

function renderSightings(data){
  const list=document.getElementById('sightingsList');
  list.innerHTML='';
  (data.items||[]).forEach(s=>{
    const li=document.createElement('li');
    li.textContent=`${s.ts} - ${s.species_guess || (s.classifications[0]?.species_name||'Unknown')} @ (${s.latitude.toFixed(3)}, ${s.longitude.toFixed(3)}) depth ${s.depth_m || '?'}m`;
    list.appendChild(li);
  });
}

// Event wiring

document.getElementById('classifyForm').addEventListener('submit', async (e)=>{
  e.preventDefault();
  const file=document.getElementById('fileInput').files[0];
  if(!file) return;
  try {
    const data=await classifyImage(file);
    renderClassifications(data);
  } catch(err){
    alert(err.message);
  }
});

document.getElementById('sightingForm').addEventListener('submit', async (e)=>{
  e.preventDefault();
  const payload={
    latitude: parseFloat(document.getElementById('latitude').value),
    longitude: parseFloat(document.getElementById('longitude').value),
    depth_m: document.getElementById('depth').value?parseFloat(document.getElementById('depth').value):null,
    species_guess: document.getElementById('speciesGuess').value||null,
    notes: document.getElementById('notes').value||null
  };
  try {
    const sight=await createSighting(payload);
    document.getElementById('sightingResult').textContent=`Saved sighting ${sight.id}`;
    const list=await listSightings();
    renderSightings(list);
  } catch(err){
    alert(err.message);
  }
});

document.getElementById('refreshSightings').addEventListener('click', async ()=>{
  try {
    const list=await listSightings();
    renderSightings(list);
  } catch(err){ alert(err.message); }
});

// Initial load
listSightings().then(renderSightings).catch(()=>{});
