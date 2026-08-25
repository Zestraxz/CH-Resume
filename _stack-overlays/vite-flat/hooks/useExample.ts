import { useEffect, useState } from 'react';

/**
 * Example hook. Replace with real hooks (auth, data fetching, etc.) as the
 * app grows. Pattern: one file per hook, named useFoo.
 */
export function useExample() {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setReady(true), 100);
    return () => clearTimeout(t);
  }, []);

  return { ready };
}
