#!/bin/bash

# Extensions Page
cat > client/src/pages/Extensions.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Switch } from "@/components/ui/switch";
import { trpc } from "@/lib/trpc";
import { Plus, Trash2, Edit, AlertCircle, Phone } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function Extensions() {
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);

  const { data: extensions, refetch } = trpc.extensions.list.useQuery();
  const createMutation = trpc.extensions.create.useMutation();
  const deleteMutation = trpc.extensions.delete.useMutation();

  const handleCreate = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    
    try {
      await createMutation.mutateAsync({
        extension: formData.get("extension") as string,
        name: formData.get("name") as string,
        secret: formData.get("secret") as string,
        callerIdName: formData.get("callerIdName") as string || undefined,
        callerIdNumber: formData.get("callerIdNumber") as string || undefined,
      });
      
      toast.success("Ramal criado com sucesso!");
      setIsCreateDialogOpen(false);
      refetch();
    } catch (error) {
      toast.error("Erro ao criar ramal");
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Tem certeza que deseja excluir este ramal?")) return;
    
    try {
      await deleteMutation.mutateAsync({ id });
      toast.success("Ramal excluído!");
      refetch();
    } catch (error) {
      toast.error("Erro ao excluir ramal");
    }
  };

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Ramais SIP</h1>
            <p className="text-muted-foreground">Configure ramais para o sistema</p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Novo Ramal
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Criar Novo Ramal</DialogTitle>
                <DialogDescription>Configure um novo ramal SIP</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleCreate}>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="extension">Número do Ramal *</Label>
                    <Input id="extension" name="extension" placeholder="1000" required />
                  </div>
                  <div>
                    <Label htmlFor="name">Nome *</Label>
                    <Input id="name" name="name" required />
                  </div>
                  <div>
                    <Label htmlFor="secret">Senha *</Label>
                    <Input id="secret" name="secret" type="password" required />
                  </div>
                  <div>
                    <Label htmlFor="callerIdName">Caller ID Nome</Label>
                    <Input id="callerIdName" name="callerIdName" />
                  </div>
                  <div>
                    <Label htmlFor="callerIdNumber">Caller ID Número</Label>
                    <Input id="callerIdNumber" name="callerIdNumber" />
                  </div>
                </div>
                <DialogFooter className="mt-6">
                  <Button type="submit" disabled={createMutation.isPending}>
                    {createMutation.isPending ? "Criando..." : "Criar"}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Lista de Ramais</CardTitle>
            <CardDescription>{extensions?.length || 0} ramal(is) configurado(s)</CardDescription>
          </CardHeader>
          <CardContent>
            {extensions && extensions.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Ramal</TableHead>
                    <TableHead>Nome</TableHead>
                    <TableHead>Caller ID</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {extensions.map((ext) => (
                    <TableRow key={ext.id}>
                      <TableCell className="font-medium">{ext.extension}</TableCell>
                      <TableCell>{ext.name}</TableCell>
                      <TableCell>{ext.callerIdName || "-"}</TableCell>
                      <TableCell>
                        {ext.enabled ? (
                          <span className="status-badge status-success">Ativo</span>
                        ) : (
                          <span className="status-badge status-error">Inativo</span>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(ext.id)}
                          disabled={deleteMutation.isPending}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <AlertCircle className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">Nenhum ramal configurado</h3>
                <p className="text-sm text-muted-foreground">Crie seu primeiro ramal</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}
EOF

# Queues Page
cat > client/src/pages/Queues.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { trpc } from "@/lib/trpc";
import { Plus, Trash2, AlertCircle } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function Queues() {
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);

  const { data: queues, refetch } = trpc.queues.list.useQuery();
  const createMutation = trpc.queues.create.useMutation();
  const deleteMutation = trpc.queues.delete.useMutation();

  const handleCreate = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    
    try {
      await createMutation.mutateAsync({
        name: formData.get("name") as string,
        displayName: formData.get("displayName") as string,
        strategy: formData.get("strategy") as any,
        timeout: parseInt(formData.get("timeout") as string),
        retry: parseInt(formData.get("retry") as string),
        maxlen: parseInt(formData.get("maxlen") as string),
      });
      
      toast.success("Fila criada com sucesso!");
      setIsCreateDialogOpen(false);
      refetch();
    } catch (error) {
      toast.error("Erro ao criar fila");
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Tem certeza que deseja excluir esta fila?")) return;
    
    try {
      await deleteMutation.mutateAsync({ id });
      toast.success("Fila excluída!");
      refetch();
    } catch (error) {
      toast.error("Erro ao excluir fila");
    }
  };

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Filas de Atendimento</h1>
            <p className="text-muted-foreground">Gerencie filas de espera e agentes</p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Nova Fila
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Criar Nova Fila</DialogTitle>
                <DialogDescription>Configure uma nova fila de atendimento</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleCreate}>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="name">Nome Técnico *</Label>
                    <Input id="name" name="name" placeholder="queue-vendas" required />
                  </div>
                  <div>
                    <Label htmlFor="displayName">Nome de Exibição *</Label>
                    <Input id="displayName" name="displayName" placeholder="Vendas" required />
                  </div>
                  <div>
                    <Label htmlFor="strategy">Estratégia *</Label>
                    <Select name="strategy" defaultValue="ringall" required>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="ringall">Ring All</SelectItem>
                        <SelectItem value="leastrecent">Least Recent</SelectItem>
                        <SelectItem value="fewestcalls">Fewest Calls</SelectItem>
                        <SelectItem value="random">Random</SelectItem>
                        <SelectItem value="rrmemory">Round Robin Memory</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="timeout">Timeout (segundos) *</Label>
                    <Input id="timeout" name="timeout" type="number" defaultValue="30" required />
                  </div>
                  <div>
                    <Label htmlFor="retry">Retry (segundos) *</Label>
                    <Input id="retry" name="retry" type="number" defaultValue="5" required />
                  </div>
                  <div>
                    <Label htmlFor="maxlen">Máximo de Chamadas *</Label>
                    <Input id="maxlen" name="maxlen" type="number" defaultValue="0" required />
                  </div>
                </div>
                <DialogFooter className="mt-6">
                  <Button type="submit" disabled={createMutation.isPending}>
                    {createMutation.isPending ? "Criando..." : "Criar"}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Lista de Filas</CardTitle>
            <CardDescription>{queues?.length || 0} fila(s) configurada(s)</CardDescription>
          </CardHeader>
          <CardContent>
            {queues && queues.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nome</TableHead>
                    <TableHead>Estratégia</TableHead>
                    <TableHead>Timeout</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {queues.map((queue) => (
                    <TableRow key={queue.id}>
                      <TableCell className="font-medium">{queue.displayName}</TableCell>
                      <TableCell>{queue.strategy}</TableCell>
                      <TableCell>{queue.timeout}s</TableCell>
                      <TableCell>
                        {queue.enabled ? (
                          <span className="status-badge status-success">Ativa</span>
                        ) : (
                          <span className="status-badge status-error">Inativa</span>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(queue.id)}
                          disabled={deleteMutation.isPending}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <AlertCircle className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">Nenhuma fila configurada</h3>
                <p className="text-sm text-muted-foreground">Crie sua primeira fila</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}
EOF

# Trunks Page
cat > client/src/pages/Trunks.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { trpc } from "@/lib/trpc";
import { Plus, Trash2, AlertCircle } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function Trunks() {
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);

  const { data: trunks, refetch } = trpc.trunks.list.useQuery();
  const createMutation = trpc.trunks.create.useMutation();
  const deleteMutation = trpc.trunks.delete.useMutation();

  const handleCreate = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    
    try {
      await createMutation.mutateAsync({
        name: formData.get("name") as string,
        host: formData.get("host") as string,
        username: formData.get("username") as string,
        secret: formData.get("secret") as string,
        port: parseInt(formData.get("port") as string),
      });
      
      toast.success("Tronco SIP criado com sucesso!");
      setIsCreateDialogOpen(false);
      refetch();
    } catch (error) {
      toast.error("Erro ao criar tronco SIP");
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Tem certeza que deseja excluir este tronco?")) return;
    
    try {
      await deleteMutation.mutateAsync({ id });
      toast.success("Tronco excluído!");
      refetch();
    } catch (error) {
      toast.error("Erro ao excluir tronco");
    }
  };

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Troncos SIP</h1>
            <p className="text-muted-foreground">Configure troncos SIP externos</p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Novo Tronco
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Criar Novo Tronco SIP</DialogTitle>
                <DialogDescription>Configure conexão com provedor SIP</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleCreate}>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="name">Nome *</Label>
                    <Input id="name" name="name" required />
                  </div>
                  <div>
                    <Label htmlFor="host">Servidor (Host) *</Label>
                    <Input id="host" name="host" placeholder="sip.provedor.com" required />
                  </div>
                  <div>
                    <Label htmlFor="username">Usuário *</Label>
                    <Input id="username" name="username" required />
                  </div>
                  <div>
                    <Label htmlFor="secret">Senha *</Label>
                    <Input id="secret" name="secret" type="password" required />
                  </div>
                  <div>
                    <Label htmlFor="port">Porta *</Label>
                    <Input id="port" name="port" type="number" defaultValue="5060" required />
                  </div>
                </div>
                <DialogFooter className="mt-6">
                  <Button type="submit" disabled={createMutation.isPending}>
                    {createMutation.isPending ? "Criando..." : "Criar"}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Lista de Troncos</CardTitle>
            <CardDescription>{trunks?.length || 0} tronco(s) configurado(s)</CardDescription>
          </CardHeader>
          <CardContent>
            {trunks && trunks.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nome</TableHead>
                    <TableHead>Host</TableHead>
                    <TableHead>Usuário</TableHead>
                    <TableHead>Porta</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {trunks.map((trunk) => (
                    <TableRow key={trunk.id}>
                      <TableCell className="font-medium">{trunk.name}</TableCell>
                      <TableCell>{trunk.host}</TableCell>
                      <TableCell>{trunk.username}</TableCell>
                      <TableCell>{trunk.port}</TableCell>
                      <TableCell>
                        {trunk.enabled ? (
                          <span className="status-badge status-success">Ativo</span>
                        ) : (
                          <span className="status-badge status-error">Inativo</span>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(trunk.id)}
                          disabled={deleteMutation.isPending}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <AlertCircle className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">Nenhum tronco configurado</h3>
                <p className="text-sm text-muted-foreground">Adicione seu primeiro tronco SIP</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}
EOF

# Reports Page
cat > client/src/pages/Reports.tsx << 'EOF'
import DashboardLayout from "@/components/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { trpc } from "@/lib/trpc";
import { AlertCircle, CheckCircle, XCircle, PhoneOff, Voicemail } from "lucide-react";
import { useState } from "react";

export default function Reports() {
  const [selectedCampaignId, setSelectedCampaignId] = useState<number | null>(null);

  const { data: campaigns } = trpc.campaigns.list.useQuery();
  const { data: callLogs } = trpc.reports.callLogs.useQuery(
    { campaignId: selectedCampaignId! },
    { enabled: !!selectedCampaignId }
  );
  const { data: stats } = trpc.reports.stats.useQuery(
    { campaignId: selectedCampaignId! },
    { enabled: !!selectedCampaignId }
  );

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Relatórios</h1>
          <p className="text-muted-foreground">Visualize métricas e logs de chamadas</p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Selecionar Campanha</CardTitle>
            <CardDescription>Escolha uma campanha para visualizar os relatórios</CardDescription>
          </CardHeader>
          <CardContent>
            <Select onValueChange={(v) => setSelectedCampaignId(parseInt(v))}>
              <SelectTrigger>
                <SelectValue placeholder="Selecione uma campanha" />
              </SelectTrigger>
              <SelectContent>
                {campaigns?.map((campaign) => (
                  <SelectItem key={campaign.id} value={campaign.id.toString()}>
                    {campaign.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </CardContent>
        </Card>

        {selectedCampaignId && stats && (
          <>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
              <StatCard
                title="Total"
                value={stats.total}
                icon={<AlertCircle className="h-4 w-4" />}
              />
              <StatCard
                title="Atendidas"
                value={stats.answered}
                icon={<CheckCircle className="h-4 w-4 text-green-500" />}
                color="green"
              />
              <StatCard
                title="Não Atendidas"
                value={stats.noAnswer}
                icon={<PhoneOff className="h-4 w-4 text-yellow-500" />}
                color="yellow"
              />
              <StatCard
                title="Ocupado"
                value={stats.busy}
                icon={<XCircle className="h-4 w-4 text-red-500" />}
                color="red"
              />
              <StatCard
                title="Caixa Postal"
                value={stats.voicemail}
                icon={<Voicemail className="h-4 w-4 text-blue-500" />}
                color="blue"
              />
            </div>

            <Card>
              <CardHeader>
                <CardTitle>Logs de Chamadas</CardTitle>
                <CardDescription>Histórico detalhado de todas as chamadas</CardDescription>
              </CardHeader>
              <CardContent>
                {callLogs && callLogs.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Telefone</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Duração</TableHead>
                        <TableHead>Opção IVR</TableHead>
                        <TableHead>Data/Hora</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {callLogs.map((log) => (
                        <TableRow key={log.id}>
                          <TableCell className="font-medium">{log.phone}</TableCell>
                          <TableCell>
                            <StatusBadge status={log.status} />
                          </TableCell>
                          <TableCell>{log.duration}s</TableCell>
                          <TableCell>{log.ivrOption || "-"}</TableCell>
                          <TableCell>
                            {new Date(log.callStartTime).toLocaleString('pt-BR')}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <div className="flex flex-col items-center justify-center py-12 text-center">
                    <AlertCircle className="h-12 w-12 text-muted-foreground mb-4" />
                    <h3 className="text-lg font-semibold mb-2">Nenhuma chamada registrada</h3>
                    <p className="text-sm text-muted-foreground">
                      As chamadas aparecerão aqui quando a campanha for executada
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </>
        )}
      </div>
    </DashboardLayout>
  );
}

interface StatCardProps {
  title: string;
  value: number;
  icon: React.ReactNode;
  color?: string;
}

function StatCard({ title, value, icon, color }: StatCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        {icon}
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
      </CardContent>
    </Card>
  );
}

function StatusBadge({ status }: { status: string }) {
  const statusMap: Record<string, string> = {
    answered: "status-badge status-success",
    "no-answer": "status-badge status-warning",
    busy: "status-badge status-error",
    failed: "status-badge status-error",
    voicemail: "status-badge status-info",
  };

  const labelMap: Record<string, string> = {
    answered: "Atendida",
    "no-answer": "Não Atendida",
    busy: "Ocupado",
    failed: "Falhou",
    voicemail: "Caixa Postal",
  };

  return (
    <span className={statusMap[status] || "status-badge"}>
      {labelMap[status] || status}
    </span>
  );
}
EOF

echo "Todas as páginas criadas com sucesso!"
