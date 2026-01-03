import { createContext, useContext, useMemo, useState } from "react";

type Role = "USER" | "ADMIN";

interface AuthState {
  address?: string;
  role: Role;
}

interface AuthContextValue extends AuthState {
  toggleRole: () => void;
  setAddress: (a?: string) => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [role, setRole] = useState<Role>("USER");
  const [address, setAddress] = useState<string | undefined>();

  const value = useMemo(
    () => ({
      role,
      address,
      toggleRole: () => setRole((r) => (r === "USER" ? "ADMIN" : "USER")),
      setAddress,
    }),
    [role, address]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}