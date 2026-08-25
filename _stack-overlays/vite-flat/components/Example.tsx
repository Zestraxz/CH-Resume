interface ExampleProps {
  count: number;
  onIncrement: () => void;
}

export function Example({ count, onIncrement }: ExampleProps) {
  return (
    <div className="example">
      <p>Count: {count}</p>
      <button type="button" onClick={onIncrement}>
        Increment
      </button>
    </div>
  );
}
