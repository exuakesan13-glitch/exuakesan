#!/bin/bash

# Contacts Page
cat > client/src/pages/Contacts.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Contacts() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Contatos</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# AudioFiles Page
cat > client/src/pages/AudioFiles.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function AudioFiles() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Arquivos de Áudio</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# Extensions Page
cat > client/src/pages/Extensions.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Extensions() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Ramais</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# Queues Page
cat > client/src/pages/Queues.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Queues() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Filas de Atendimento</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# Trunks Page
cat > client/src/pages/Trunks.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Trunks() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Troncos SIP</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# Campaigns Page
cat > client/src/pages/Campaigns.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Campaigns() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Campanhas</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

# Reports Page
cat > client/src/pages/Reports.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
export default function Reports() {
  return (
    <DashboardLayout>
      <div className="p-6">
        <h1 className="text-3xl font-bold">Relatórios</h1>
        <p className="text-muted-foreground">Página em desenvolvimento</p>
      </div>
    </DashboardLayout>
  );
}
EOF

echo "Páginas criadas com sucesso!"
