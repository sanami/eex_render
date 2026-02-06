document.addEventListener('DOMContentLoaded', () => {
  let btn = document.querySelector("#get-html");
  if (btn) {
    btn.addEventListener('click', async () => {
      const response = await fetch('/get-html', {method: 'POST'});
      const body = await response.text();
      document.querySelector('#result').innerHTML = body;
    });
  }

  btn = document.querySelector("#get-json");
  if (btn) {
    btn.addEventListener('click', async () => {
      const response = await fetch('/get-json', {method: 'POST'});
      const json = await response.json();
      document.querySelector('#result').textContent = JSON.stringify(json);
    });
  }
});
