import { useState } from 'react';
import { Example } from './components/Example';
import { useExample } from './hooks/useExample';
import { APP_NAME } from './constants';

export default function App() {
  const [count, setCount] = useState(0);
  const { ready } = useExample();

  return (
    <div className="app">
      <h1>{APP_NAME}</h1>
      <p>{ready ? 'Ready.' : 'Loading...'}</p>
      <Example count={count} onIncrement={() => setCount(count + 1)} />
    </div>
  );
}
