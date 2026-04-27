interface SubmitButtonProps {
  loading: boolean;
  label: string;
  loadingLabel: string;
  disabled?: boolean;
}

export default function SubmitButton({ loading, label, loadingLabel, disabled }: SubmitButtonProps) {
  return (
    <button
      type="submit"
      disabled={loading || disabled}
      className="w-full py-2 px-4 bg-accent text-accent-fg text-sm font-medium rounded-lg hover:bg-accent-hover disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
    >
      {loading ? loadingLabel : label}
    </button>
  );
}
