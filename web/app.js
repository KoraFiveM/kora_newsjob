const root = ReactDOM.createRoot(document.getElementById('root'));
const Lens = () => React.createElement('main', null,
  React.createElement('span', { className: 'rec' }, '● REC'),
  React.createElement('span', { className: 'title' }, 'WEAZEL NEWS'),
  React.createElement('div', { className: 'frame' }),
  React.createElement('span', { className: 'hint' }, 'ESC TO STOP'));
window.addEventListener('message', ({ data }) => root.render(data.action === 'open' ? React.createElement(Lens) : null));
