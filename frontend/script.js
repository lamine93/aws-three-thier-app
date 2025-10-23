// Configuration de l'API
// Modifiez cette URL avec l'adresse de votre ALB/API
const API_BASE_URL = 'http://three-tier-app-alb-1452960188.us-east-1.elb.amazonaws.com';

// Utilitaires DOM
const $ = (id) => document.getElementById(id);
const show = (el) => el.classList.add('show');
const hide = (el) => el.classList.remove('show');

// Fonction helper pour les requêtes API
async function apiCall(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`;
  
  try {
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...options.headers
      },
      ...options
    });

    const text = await response.text();
    let data;
    
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }

    if (!response.ok) {
      throw {
        status: response.status,
        statusText: response.statusText,
        body: data
      };
    }

    return data;
  } catch (error) {
    if (error.status) {
      throw error;
    }
    throw {
      status: 0,
      statusText: 'Network Error',
      body: error.message
    };
  }
}

// Fonction pour afficher un message
function showMessage(message, type = 'info') {
  const msgEl = $('userMessage');
  msgEl.textContent = message;
  msgEl.className = `message ${type} show`;
  
  setTimeout(() => {
    hide(msgEl);
  }, 5000);
}

// Fonction pour échapper le HTML
function escapeHtml(text) {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;'
  };
  return String(text).replace(/[&<>"']/g, (m) => map[m]);
}

// ==================== HEALTH CHECK ====================

async function checkHealth() {
  const statusBadge = $('healthStatus');
  const output = $('healthOutput');
  
  statusBadge.textContent = 'Vérification...';
  statusBadge.className = 'badge badge-waiting';
  hide(output);
  
  try {
    const data = await apiCall('/health');
    
    statusBadge.textContent = 'Opérationnel ✓';
    statusBadge.className = 'badge badge-success';
    
    output.textContent = JSON.stringify(data, null, 2);
    show(output);
  } catch (error) {
    statusBadge.textContent = 'Erreur ✗';
    statusBadge.className = 'badge badge-error';
    
    const errorMsg = error.status 
      ? `HTTP ${error.status} - ${error.statusText}\n${JSON.stringify(error.body, null, 2)}`
      : `Erreur réseau: ${error.body}`;
    
    output.textContent = errorMsg;
    show(output);
  }
}

// ==================== USERS MANAGEMENT ====================

// Lister tous les utilisateurs
async function listUsers() {
  const tbody = $('usersBody');
  const msgEl = $('userMessage');
  
  tbody.innerHTML = '<tr><td colspan="4" class="empty-state">Chargement...</td></tr>';
  hide(msgEl);
  
  try {
    const users = await apiCall('/api/users');
    
    if (!Array.isArray(users) || users.length === 0) {
      tbody.innerHTML = '<tr><td colspan="4" class="empty-state">Aucun utilisateur trouvé</td></tr>';
      showMessage('Aucun utilisateur dans la base de données', 'info');
      return;
    }
    
    tbody.innerHTML = users.map(user => `
      <tr>
        <td>${escapeHtml(user.name)}</td>
        <td>${escapeHtml(user.email)}</td>
        <td><code>${escapeHtml(user.id)}</code></td>
        <td>
          <button 
            class="btn btn-danger" 
            onclick="deleteUser('${escapeHtml(user.id)}')"
          >
            🗑️ Supprimer
          </button>
        </td>
      </tr>
    `).join('');
    
    showMessage(`${users.length} utilisateur(s) chargé(s)`, 'success');
  } catch (error) {
    tbody.innerHTML = '<tr><td colspan="4" class="empty-state">Erreur lors du chargement</td></tr>';
    
    const errorMsg = error.status 
      ? `Erreur ${error.status}: ${error.statusText}`
      : 'Impossible de se connecter à l\'API';
    
    showMessage(errorMsg, 'error');
    console.error('Error listing users:', error);
  }
}

// Ajouter un utilisateur
async function addUser() {
  const nameInput = $('userName');
  const emailInput = $('userEmail');
  const name = nameInput.value.trim();
  const email = emailInput.value.trim();
  
  if (!name || !email) {
    showMessage('Le nom et l\'email sont obligatoires', 'error');
    return;
  }
  
  // Validation simple de l'email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    showMessage('Format d\'email invalide', 'error');
    return;
  }
  
  showMessage('Création en cours...', 'info');
  
  try {
    await apiCall('/api/users', {
      method: 'POST',
      body: JSON.stringify({ name, email })
    });
    
    showMessage(`Utilisateur "${name}" créé avec succès!`, 'success');
    
    // Réinitialiser le formulaire
    nameInput.value = '';
    emailInput.value = '';
    
    // Rafraîchir la liste
    await listUsers();
  } catch (error) {
    const errorMsg = error.status 
      ? `Erreur ${error.status}: ${error.statusText}`
      : 'Impossible de créer l\'utilisateur';
    
    showMessage(errorMsg, 'error');
    console.error('Error adding user:', error);
  }
}

// Supprimer un utilisateur
async function deleteUser(userId) {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer l'utilisateur ${userId} ?`)) {
    return;
  }
  
  showMessage('Suppression en cours...', 'info');
  
  try {
    await apiCall(`/api/users/${userId}`, {
      method: 'DELETE'
    });
    
    showMessage('Utilisateur supprimé avec succès!', 'success');
    
    // Rafraîchir la liste
    await listUsers();
  } catch (error) {
    const errorMsg = error.status 
      ? `Erreur ${error.status}: ${error.statusText}`
      : 'Impossible de supprimer l\'utilisateur';
    
    showMessage(errorMsg, 'error');
    console.error('Error deleting user:', error);
  }
}

// ==================== EVENT LISTENERS ====================

// Health check
$('btnHealth').addEventListener('click', checkHealth);

// Users management
$('btnList').addEventListener('click', listUsers);
$('btnAdd').addEventListener('click', addUser);

// Permettre d'ajouter avec la touche Enter
$('userName').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') addUser();
});

$('userEmail').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') addUser();
});

// ==================== INITIALISATION ====================

console.log('Three-Tier Frontend loaded');
console.log('API Base URL:', API_BASE_URL);

// Vérifier si l'URL de l'API est configurée
if (API_BASE_URL.includes('your-alb-dns-here')) {
  console.warn('⚠️ Veuillez configurer l\'API_BASE_URL dans script.js');
}

// Rendre la fonction deleteUser accessible globalement pour les boutons
window.deleteUser = deleteUser;