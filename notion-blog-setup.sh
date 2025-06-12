#!/bin/zsh

# notion-blog-setup.sh - Automated setup script for Notion blog integration
# This script automates the setup process and monitors for errors

# Log file setup
LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/notion_blog_setup_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging function
log() {
  local level="$1"
  local message="$2"
  local color="$NC"
  
  case "$level" in
    "INFO") color="$GREEN" ;;
    "WARN") color="$YELLOW" ;;
    "ERROR") color="$RED" ;;
  esac
  
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo -e "${color}[$timestamp] [$level] $message${NC}"
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Error handling function
handle_error() {
  local exit_code=$1
  local error_message=$2
  
  if [[ $exit_code -ne 0 ]]; then
    log "ERROR" "$error_message (Exit code: $exit_code)"
    log "INFO" "Check the log file for details: $LOG_FILE"
    exit $exit_code
  fi
}

# Check if 1Password CLI is installed
check_1password_cli() {
  log "INFO" "Checking if 1Password CLI is installed..."
  if ! command -v op &> /dev/null; then
    log "ERROR" "1Password CLI is not installed. Please install it first."
    log "INFO" "You can install it with: brew install 1password-cli"
    exit 1
  fi
  log "INFO" "1Password CLI is installed ✓"
}

# Check if user is signed in to 1Password
check_1password_signin() {
  log "INFO" "Checking 1Password authentication status..."
  if ! op account list &> /dev/null; then
    log "WARN" "Not signed in to 1Password. Please sign in."
    op signin
    handle_error $? "Failed to sign in to 1Password"
  fi
  log "INFO" "Authenticated with 1Password ✓"
}

# Create API directory if it doesn't exist
setup_api_directory() {
  log "INFO" "Setting up API directory..."
  local API_DIR="/Volumes/DATA/Git/ai-product-notes/scripts/sayvainc-blog/pages/api"
  mkdir -p "$API_DIR"
  handle_error $? "Failed to create API directory"
  log "INFO" "API directory created: $API_DIR ✓"
  
  return 0
}

# Create get-posts.js API endpoint
create_api_endpoint() {
  log "INFO" "Creating Notion API endpoint..."
  local API_FILE="/Volumes/DATA/Git/ai-product-notes/scripts/sayvainc-blog/pages/api/get-posts.js"
  
  cat > "$API_FILE" << 'EOF'
import { Client } from '@notionhq/client';

export default async function handler(req, res) {
  try {
    const notion = new Client({ 
      auth: process.env.NOTION_API_KEY 
    });
    
    const databaseId = process.env.NOTION_DATABASE_ID;
    
    const response = await notion.databases.query({
      database_id: databaseId,
      sorts: [
        {
          property: 'Published Date',
          direction: 'descending',
        },
      ],
    });
    
    // Get page content for each post
    const posts = await Promise.all(
      response.results.map(async (page) => {
        try {
          // Get blocks for the page content
          const blocks = await notion.blocks.children.list({
            block_id: page.id,
          });
          
          // Convert blocks to HTML
          const content = convertBlocksToHtml(blocks.results);
          
          return {
            ...page,
            content
          };
        } catch (error) {
          console.error(`Error fetching content for page ${page.id}:`, error);
          return {
            ...page,
            content: '<p>Error loading content.</p>'
          };
        }
      })
    );
    
    res.status(200).json(posts);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
}

// Convert Notion blocks to HTML
function convertBlocksToHtml(blocks) {
  let html = '';
  
  blocks.forEach(block => {
    if (block.type === 'paragraph') {
      const text = block.paragraph.rich_text.map(t => t.text.content).join('');
      html += `<p>${text}</p>`;
    } else if (block.type === 'heading_2') {
      const text = block.heading_2.rich_text.map(t => t.text.content).join('');
      html += `<h2>${text}</h2>`;
    } else if (block.type === 'heading_3') {
      const text = block.heading_3.rich_text.map(t => t.text.content).join('');
      html += `<h3>${text}</h3>`;
    } else if (block.type === 'bulleted_list_item') {
      const text = block.bulleted_list_item.rich_text.map(t => t.text.content).join('');
      html += `<ul><li>${text}</li></ul>`;
    }
  });
  
  return html;
}
EOF

  handle_error $? "Failed to create API endpoint file"
  log "INFO" "API endpoint created: $API_FILE ✓"
  
  return 0
}

# Create environment variables loader script
create_env_loader() {
  log "INFO" "Creating environment variables loader script..."
  local LOADER_FILE="/Volumes/DATA/Git/ai-product-notes/scripts/sayvainc-blog/load-secrets.sh"
  
  cat > "$LOADER_FILE" << 'EOF'
#!/bin/zsh

# Get Notion API credentials from 1Password
export NOTION_API_KEY=$(op item get "Notion Blog API" --fields apiKey)
export NOTION_DATABASE_ID=$(op item get "Notion Blog API" --fields databaseId)

# Run the development server with the environment variables
npm run dev
EOF

  chmod +x "$LOADER_FILE"
  handle_error $? "Failed to make loader script executable"
  log "INFO" "Environment loader created: $LOADER_FILE ✓"
  
  return 0
}

# Create package.json if it doesn't exist
create_package_json() {
  log "INFO" "Checking for package.json..."
  local PACKAGE_FILE="/Volumes/DATA/Git/ai-product-notes/scripts/sayvainc-blog/package.json"
  
  if [[ ! -f "$PACKAGE_FILE" ]]; then
    log "INFO" "Creating package.json..."
    cat > "$PACKAGE_FILE" << 'EOF'
{
  "name": "sayvainc-blog",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "@notionhq/client": "^2.2.14",
    "lucide-react": "^0.294.0",
    "next": "^14.0.4",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
EOF
    handle_error $? "Failed to create package.json"
    log "INFO" "package.json created ✓"
  else
    log "INFO" "package.json already exists ✓"
  fi
  
  return 0
}

# Create instructions for Notion setup
create_notion_instructions() {
  log "INFO" "Creating Notion setup instructions..."
  local INSTRUCTIONS_FILE="/Volumes/DATA/Git/ai-product-notes/scripts/sayvainc-blog/NOTION_SETUP.md"
  
  cat > "$INSTRUCTIONS_FILE" << 'EOF'
# Notion Blog Setup Instructions

## 1. Create a Notion Database

1. In Notion, click "+ New page" and select "Table - Database"
2. Add these properties to match your code:
   - Post Title (Title type)
   - Summary (Text type)
   - Tags (Multi-select type)
   - Author (Text type)
   - Published Date (Date type)
   - ReadTime (Number type)
   - Slug (Text type)
   - ImageURL (URL type)

## 2. Set Up Notion API Integration

1. Go to [https://www.notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Click "New integration"
3. Name it "Blog Integration" and select your workspace
4. Under "Capabilities", enable "Read content"
5. Save and copy your "Internal Integration Token"
6. Go to your database in Notion, click "Share" and invite your integration

## 3. Store Credentials in 1Password

```bash
# Create an entry for your Notion API key
op item create --category="API Credential" \
  --title="Notion Blog API" \
  --vault="Development" \
  --url="https://www.notion.so" \
  "apiKey=your_notion_api_key" \
  "databaseId=your_notion_database_id"
```

## 4. Run the Development Server

```bash
# Install dependencies
npm install

# Start the development server with credentials from 1Password
./load-secrets.sh
```
EOF

  handle_error $? "Failed to create Notion setup instructions"
  log "INFO" "Notion setup instructions created: $INSTRUCTIONS_FILE ✓"
  
  return 0
}

# Main execution
main() {
  log "INFO" "Starting Notion blog setup process..."
  
  check_1password_cli
  check_1password_signin
  setup_api_directory
  create_api_endpoint
  create_env_loader
  create_package_json
  create_notion_instructions
  
  log "INFO" "Setup completed successfully! ✓"
  log "INFO" "Next steps:"
  log "INFO" "1. Follow the instructions in NOTION_SETUP.md to set up your Notion database"
  log "INFO" "2. Store your credentials in 1Password"
  log "INFO" "3. Run './load-secrets.sh' to start the development server"
  log "INFO" "Log file: $LOG_FILE"
}

# Run the main function
main