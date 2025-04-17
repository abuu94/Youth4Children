#!/bin/bash

# Firebase React Chat App Generator Script
# This script sets up a complete React messaging app with Firebase integration

echo "🚀 Generating Firebase React Chat App..."

# Create the project directory
PROJECT_NAME="firebase-react-chat"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Initialize a new React app with TypeScript
echo "📦 Creating React app with TypeScript..."
npx create-react-app . --template typescript

# Install dependencies
echo "📚 Installing dependencies..."
npm install @mui/material @mui/icons-material @emotion/react @emotion/styled firebase framer-motion date-fns uuid react-router-dom

# Create project structure
echo "🏗️ Creating project structure..."
mkdir -p src/components/auth
mkdir -p src/components/chat
mkdir -p src/components/layout
mkdir -p src/components/ui
mkdir -p src/context
mkdir -p src/hooks
mkdir -p src/services
mkdir -p src/utils
mkdir -p src/pages
mkdir -p src/types

# Create Firebase configuration
cat > src/services/firebase.ts << 'EOL'
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Replace with your own Firebase config
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const googleProvider = new GoogleAuthProvider();

// Configure Google provider
googleProvider.setCustomParameters({
  prompt: 'select_account'
});
EOL

# Create authentication context
cat > src/context/AuthContext.tsx << 'EOL'
import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { 
  User, 
  onAuthStateChanged, 
  signInWithPopup, 
  signOut as firebaseSignOut
} from "firebase/auth";
import { auth, googleProvider } from "../services/firebase";

interface AuthContextType {
  currentUser: User | null;
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const signInWithGoogle = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error("Error signing in with Google:", error);
    }
  };

  const signOut = async () => {
    try {
      await firebaseSignOut(auth);
    } catch (error) {
      console.error("Error signing out:", error);
    }
  };

  const value = {
    currentUser,
    loading,
    signInWithGoogle,
    signOut
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};
EOL

# Create message types
cat > src/types/message.ts << 'EOL'
export interface Message {
  id: string;
  text: string;
  senderId: string;
  senderName: string;
  senderPhotoURL: string;
  createdAt: Date;
  imageUrl?: string;
  reactions?: Record<string, string>; // userId: reactionType
}

export interface UserTyping {
  userId: string;
  userName: string;
  timestamp: Date;
}
EOL

# Create App theme
cat > src/theme.ts << 'EOL'
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#3f51b5',
      light: '#757de8',
      dark: '#002984',
      contrastText: '#fff',
    },
    secondary: {
      main: '#f50057',
      light: '#ff5983',
      dark: '#bb002f',
      contrastText: '#fff',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 500,
    },
    h2: {
      fontWeight: 500,
    },
    h3: {
      fontWeight: 500,
    },
    h4: {
      fontWeight: 500,
    },
    h5: {
      fontWeight: 500,
    },
    h6: {
      fontWeight: 500,
    },
  },
  shape: {
    borderRadius: 8,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          borderRadius: 28,
          padding: '8px 22px',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16,
          boxShadow: '0 4px 20px rgba(0,0,0,0.05)',
        },
      },
    },
  },
});

export default theme;
EOL

# Create Login page
cat > src/pages/Login.tsx << 'EOL'
import { Box, Button, Container, Paper, Typography } from "@mui/material";
import GoogleIcon from "@mui/icons-material/Google";
import { motion } from "framer-motion";
import { useAuth } from "../context/AuthContext";

const Login = () => {
  const { signInWithGoogle } = useAuth();

  return (
    <Container maxWidth="sm" sx={{ height: "100vh", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        style={{ width: "100%" }}
      >
        <Paper elevation={3} sx={{ p: 4, borderRadius: 4 }}>
          <Box textAlign="center" mb={4}>
            <Typography variant="h4" component="h1" gutterBottom>
              Chat App
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Connect and chat in real-time
            </Typography>
          </Box>
          <Button
            variant="contained"
            fullWidth
            size="large"
            startIcon={<GoogleIcon />}
            onClick={signInWithGoogle}
            sx={{ py: 1.5 }}
          >
            Sign in with Google
          </Button>
        </Paper>
      </motion.div>
    </Container>
  );
};

export default Login;
EOL

# Create Chat page
cat > src/pages/Chat.tsx << 'EOL'
import { useEffect, useState } from "react";
import { Box, Container, Paper } from "@mui/material";
import MessageList from "../components/chat/MessageList";
import MessageInput from "../components/chat/MessageInput";
import ChatHeader from "../components/chat/ChatHeader";
import { db } from "../services/firebase";
import { useAuth } from "../context/AuthContext";
import { Message } from "../types/message";
import { collection, query, orderBy, onSnapshot, addDoc, serverTimestamp } from "firebase/firestore";
import { v4 as uuidv4 } from "uuid";

const Chat = () => {
  const { currentUser } = useAuth();
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!currentUser) return;

    const messagesRef = collection(db, "messages");
    const q = query(messagesRef, orderBy("createdAt", "asc"));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const messagesData = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          text: data.text,
          senderId: data.senderId,
          senderName: data.senderName,
          senderPhotoURL: data.senderPhotoURL,
          createdAt: data.createdAt?.toDate() || new Date(),
          imageUrl: data.imageUrl,
          reactions: data.reactions,
        } as Message;
      });
      setMessages(messagesData);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [currentUser]);

  const sendMessage = async (text: string, imageUrl?: string) => {
    if (!currentUser || (!text.trim() && !imageUrl)) return;

    try {
      await addDoc(collection(db, "messages"), {
        id: uuidv4(),
        text,
        senderId: currentUser.uid,
        senderName: currentUser.displayName,
        senderPhotoURL: currentUser.photoURL,
        createdAt: serverTimestamp(),
        imageUrl,
      });
    } catch (error) {
      console.error("Error sending message:", error);
    }
  };

  return (
    <Container maxWidth="md" sx={{ height: "100vh", py: 2 }}>
      <Paper elevation={3} sx={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column", borderRadius: 4 }}>
        <ChatHeader />
        <Box sx={{ flexGrow: 1, overflow: "hidden" }}>
          <MessageList messages={messages} currentUser={currentUser} loading={loading} />
        </Box>
        <MessageInput onSendMessage={sendMessage} />
      </Paper>
    </Container>
  );
};

export default Chat;
EOL

# Create Header component
cat > src/components/chat/ChatHeader.tsx << 'EOL'
import { AppBar, Avatar, Box, IconButton, Toolbar, Typography } from "@mui/material";
import ExitToAppIcon from "@mui/icons-material/ExitToApp";
import { useAuth } from "../../context/AuthContext";

const ChatHeader = () => {
  const { currentUser, signOut } = useAuth();

  return (
    <AppBar position="static" color="primary" elevation={0} sx={{ borderRadius: "16px 16px 0 0" }}>
      <Toolbar>
        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          Chat Room
        </Typography>
        <Box sx={{ display: "flex", alignItems: "center" }}>
          <Typography variant="body2" sx={{ mr: 2 }}>
            {currentUser?.displayName}
          </Typography>
          <Avatar 
            src={currentUser?.photoURL || undefined} 
            alt={currentUser?.displayName || "User"} 
            sx={{ width: 32, height: 32, mr: 2 }}
          />
          <IconButton color="inherit" onClick={signOut}>
            <ExitToAppIcon />
          </IconButton>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default ChatHeader;
EOL

# Create MessageList component
cat > src/components/chat/MessageList.tsx << 'EOL'
import { useRef, useEffect } from "react";
import { Box, CircularProgress, Typography } from "@mui/material";
import { motion } from "framer-motion";
import { User } from "firebase/auth";
import { Message } from "../../types/message";
import MessageBubble from "./MessageBubble";

interface MessageListProps {
  messages: Message[];
  currentUser: User | null;
  loading: boolean;
}

const MessageList = ({ messages, currentUser, loading }: MessageListProps) => {
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const messageVariants = {
    initial: { opacity: 0, y: 20 },
    animate: { opacity: 1, y: 0 },
  };

  if (loading) {
    return (
      <Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100%" }}>
        <CircularProgress />
      </Box>
    );
  }

  if (messages.length === 0) {
    return (
      <Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100%" }}>
        <Typography variant="body1" color="text.secondary">
          No messages yet. Start the conversation!
        </Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 2, overflowY: "auto", height: "100%" }}>
      {messages.map((message, index) => (
        <motion.div
          key={message.id}
          variants={messageVariants}
          initial="initial"
          animate="animate"
          transition={{ duration: 0.3, delay: Math.min(0.1 * index, 1) }}
        >
          <MessageBubble
            message={message}
            isOwnMessage={message.senderId === currentUser?.uid}
          />
        </motion.div>
      ))}
      <div ref={messagesEndRef} />
    </Box>
  );
};

export default MessageList;
EOL

# Create MessageBubble component
cat > src/components/chat/MessageBubble.tsx << 'EOL'
import { useState } from "react";
import { Avatar, Box, IconButton, Paper, Tooltip, Typography } from "@mui/material";
import { formatDistanceToNow } from "date-fns";
import ThumbUpIcon from "@mui/icons-material/ThumbUp";
import FavoriteIcon from "@mui/icons-material/Favorite";
import { Message } from "../../types/message";
import { doc, updateDoc } from "firebase/firestore";
import { db } from "../../services/firebase";
import { useAuth } from "../../context/AuthContext";

interface MessageBubbleProps {
  message: Message;
  isOwnMessage: boolean;
}

const MessageBubble = ({ message, isOwnMessage }: MessageBubbleProps) => {
  const { currentUser } = useAuth();
  const [showReactions, setShowReactions] = useState(false);

  const addReaction = async (reaction: string) => {
    if (!currentUser) return;
    
    try {
      const messageRef = doc(db, "messages", message.id);
      const updatedReactions = {
        ...(message.reactions || {}),
        [currentUser.uid]: reaction,
      };
      
      await updateDoc(messageRef, {
        reactions: updatedReactions,
      });
    } catch (error) {
      console.error("Error adding reaction:", error);
    }
  };

  const reactionCount = message.reactions ? Object.values(message.reactions).length : 0;

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: isOwnMessage ? "row-reverse" : "row",
        alignItems: "flex-end",
        mb: 2,
      }}
      onMouseEnter={() => setShowReactions(true)}
      onMouseLeave={() => setShowReactions(false)}
    >
      {!isOwnMessage && (
        <Avatar 
          src={message.senderPhotoURL} 
          alt={message.senderName} 
          sx={{ width: 32, height: 32, mr: 1 }}
        />
      )}
      <Box sx={{ maxWidth: "70%" }}>
        {!isOwnMessage && (
          <Typography variant="caption" color="text.secondary" sx={{ ml: 1, mb: 0.5, display: "block" }}>
            {message.senderName}
          </Typography>
        )}
        <Paper
          elevation={1}
          sx={{
            p: 2,
            borderRadius: isOwnMessage ? "20px 20px 4px 20px" : "20px 20px 20px 4px",
            bgcolor: isOwnMessage ? "primary.main" : "grey.100",
            color: isOwnMessage ? "white" : "text.primary",
            position: "relative",
          }}
        >
          <Typography variant="body1">{message.text}</Typography>
          {message.imageUrl && (
            <Box sx={{ mt: 1, maxWidth: "100%" }}>
              <img 
                src={message.imageUrl} 
                alt="Attached media" 
                style={{ maxWidth: "100%", borderRadius: 8 }} 
              />
            </Box>
          )}
          <Typography
            variant="caption"
            sx={{
              display: "block",
              textAlign: "right",
              mt: 0.5,
              color: isOwnMessage ? "rgba(255,255,255,0.7)" : "text.secondary",
            }}
          >
            {formatDistanceToNow(message.createdAt, { addSuffix: true })}
          </Typography>
          
          {/* Reaction buttons */}
          {showReactions && (
            <Paper
              elevation={3}
              sx={{
                position: "absolute",
                top: "-30px",
                left: isOwnMessage ? "auto" : "20px",
                right: isOwnMessage ? "20px" : "auto",
                display: "flex",
                p: 0.5,
                borderRadius: 5,
              }}
            >
              <Tooltip title="Like">
                <IconButton size="small" onClick={() => addReaction("like")}>
                  <ThumbUpIcon fontSize="small" />
                </IconButton>
              </Tooltip>
              <Tooltip title="Love">
                <IconButton size="small" onClick={() => addReaction("love")}>
                  <FavoriteIcon fontSize="small" color="error" />
                </IconButton>
              </Tooltip>
            </Paper>
          )}
          
          {/* Reaction count */}
          {reactionCount > 0 && (
            <Box
              sx={{
                position: "absolute",
                bottom: "-10px",
                right: isOwnMessage ? "auto" : "-10px",
                left: isOwnMessage ? "-10px" : "auto",
                bgcolor: "background.paper",
                borderRadius: "50%",
                width: 24,
                height: 24,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                border: "1px solid",
                borderColor: "divider",
              }}
            >
              <Typography variant="caption">{reactionCount}</Typography>
            </Box>
          )}
        </Paper>
      </Box>
    </Box>
  );
};

export default MessageBubble;
EOL

# Create MessageInput component
cat > src/components/chat/MessageInput.tsx << 'EOL'
import { useState, ChangeEvent, FormEvent } from "react";
import { Box, IconButton, InputAdornment, TextField } from "@mui/material";
import SendIcon from "@mui/icons-material/Send";
import ImageIcon from "@mui/icons-material/Image";
import { motion } from "framer-motion";
import { getStorage, ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { useAuth } from "../../context/AuthContext";

interface MessageInputProps {
  onSendMessage: (text: string, imageUrl?: string) => void;
}

const MessageInput = ({ onSendMessage }: MessageInputProps) => {
  const { currentUser } = useAuth();
  const [message, setMessage] = useState("");
  const [isUploading, setIsUploading] = useState(false);
  const storage = getStorage();

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (message.trim() || isUploading) {
      onSendMessage(message);
      setMessage("");
    }
  };

  const handleImageUpload = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !currentUser) return;

    try {
      setIsUploading(true);
      
      // Create a reference to the file in Firebase Storage
      const storageRef = ref(storage, `images/${currentUser.uid}/${Date.now()}_${file.name}`);
      
      // Upload the file
      await uploadBytes(storageRef, file);
      
      // Get the download URL
      const downloadUrl = await getDownloadURL(storageRef);
      
      // Send the message with the image URL
      onSendMessage(message, downloadUrl);
      setMessage("");
    } catch (error) {
      console.error("Error uploading image:", error);
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <Box sx={{ p: 2, bgcolor: "background.paper" }}>
      <form onSubmit={handleSubmit}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="Type a message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          InputProps={{
            endAdornment: (
              <InputAdornment position="end">
                <input
                  accept="image/*"
                  id="image-upload"
                  type="file"
                  style={{ display: "none" }}
                  onChange={handleImageUpload}
                />
                <label htmlFor="image-upload">
                  <IconButton component="span" color="primary">
                    <ImageIcon />
                  </IconButton>
                </label>
                <motion.div whileTap={{ scale: 0.9 }}>
                  <IconButton type="submit" color="primary" disabled={!message.trim() && !isUploading}>
                    <SendIcon />
                  </IconButton>
                </motion.div>
              </InputAdornment>
            ),
          }}
          sx={{
            "& .MuiOutlinedInput-root": {
              borderRadius: 5,
            },
          }}
        />
      </form>
    </Box>
  );
};

export default MessageInput;
EOL

# Create typing indicator hook
cat > src/hooks/useTypingIndicator.ts << 'EOL'
import { useEffect, useState } from "react";
import { collection, doc, setDoc, onSnapshot, query, where, deleteDoc, Timestamp } from "firebase/firestore";
import { debounce } from "lodash";
import { db } from "../services/firebase";
import { useAuth } from "../context/AuthContext";
import { UserTyping } from "../types/message";

export const useTypingIndicator = (chatId: string = "global") => {
  const { currentUser } = useAuth();
  const [typingUsers, setTypingUsers] = useState<UserTyping[]>([]);

  useEffect(() => {
    if (!currentUser) return;

    // Set up listener for typing indicators
    const typingRef = collection(db, "typing");
    const typingQuery = query(typingRef, where("chatId", "==", chatId));

    const unsubscribe = onSnapshot(typingQuery, (snapshot) => {
      const users: UserTyping[] = [];
      
      snapshot.forEach((doc) => {
        const data = doc.data();
        // Don't show the current user as typing
        if (data.userId !== currentUser.uid) {
          users.push({
            userId: data.userId,
            userName: data.userName,
            timestamp: data.timestamp.toDate(),
          });
        }
      });
      
      // Filter out stale typing indicators (older than 10 seconds)
      const recentUsers = users.filter(
        (user) => new Date().getTime() - user.timestamp.getTime() < 10000
      );
      
      setTypingUsers(recentUsers);
    });

    return () => unsubscribe();
  }, [currentUser, chatId]);

  // Create a debounced function to update typing status
  const setTyping = debounce(async (isTyping: boolean) => {
    if (!currentUser) return;

    const typingDocRef = doc(db, "typing", currentUser.uid);

    try {
      if (isTyping) {
        // Set typing status
        await setDoc(typingDocRef, {
          userId: currentUser.uid,
          userName: currentUser.displayName,
          chatId,
          timestamp: Timestamp.now(),
        });
      } else {
        // Remove typing status
        await deleteDoc(typingDocRef);
      }
    } catch (error) {
      console.error("Error updating typing status:", error);
    }
  }, 500);

  const startTyping = () => setTyping(true);
  const stopTyping = () => setTyping(false);

  return { typingUsers, startTyping, stopTyping };
};
EOL

# Create TypingIndicator component
cat > src/components/chat/TypingIndicator.tsx << 'EOL'
import { Box, Typography } from "@mui/material";
import { motion } from "framer-motion";
import { UserTyping } from "../../types/message";

interface TypingIndicatorProps {
  typingUsers: UserTyping[];
}

const TypingIndicator = ({ typingUsers }: TypingIndicatorProps) => {
  if (typingUsers.length === 0) return null;

  const dotVariants = {
    initial: { y: 0 },
    animate: { y: [0, -5, 0] },
  };

  const formatTypingText = () => {
    if (typingUsers.length === 1) {
      return `${typingUsers[0].userName} is typing`;
    } else if (typingUsers.length === 2) {
      return `${typingUsers[0].userName} and ${typingUsers[1].userName} are typing`;
    } else {
      return `${typingUsers.length} people are typing`;
    }
  };

  return (
    <Box sx={{ p: 1, display: "flex", alignItems: "center" }}>
      <Typography variant="caption" color="text.secondary">
        {formatTypingText()}
      </Typography>
      <Box sx={{ display: "flex", ml: 1 }}>
        {[0, 1, 2].map((i) => (
          <motion.div
            key={i}
            variants={dotVariants}
            initial="initial"
            animate="animate"
            transition={{
              duration: 0.5,
              repeat: Infinity,
              repeatType: "loop",
              delay: i * 0.15,
            }}
          >
            <Typography variant="caption" color="text.secondary" sx={{ mx: 0.1 }}>
              •
            </Typography>
          </motion.div>
        ))}
      </Box>
    </Box>
  );
};

export default TypingIndicator;
EOL

# Update App.tsx
cat > src/App.tsx << 'EOL'
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { AuthProvider, useAuth } from "./context/AuthContext";
import Login from "./pages/Login";
import Chat from "./pages/Chat";
import theme from "./theme";

// Protected route component
const ProtectedRoute = ({ children }: { children: JSX.Element }) => {
  const { currentUser, loading } = useAuth();
  
  if (loading) {
    return <div>Loading...</div>;
  }
  
  if (!currentUser) {
    return <Navigate to="/login" />;
  }
  
  return children;
};

const AppRoutes = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route 
          path="/" 
          element={
            <ProtectedRoute>
              <Chat />
            </ProtectedRoute>
          } 
        />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
};

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
EOL

# Update index.css for better styling
cat > src/index.css << 'EOL'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f0f2f5;
  overflow: hidden;
}

* {
  box-sizing: border-box;
}

::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background-color: rgba(0, 0, 0, 0.2);
  border-radius: 20px;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
EOL

# Create README file
cat > README.md << 'EOL'
# Firebase React Chat Application

A real-time messaging application built with React and Firebase.

## Features

- Google Sign-In authentication
- Real-time message syncing
- Modern UI with message bubbles
- User avatars and timestamps
- Message reactions (like, love)
- Image sharing capabilities
- Typing indicators
- Responsive design with animations

## Tech Stack

- **Frontend**: React.js with TypeScript
- **UI Library**: Material-UI
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Animation**: Framer Motion
- **Routing**: React Router DOM

## Setup Instructions

1. Clone this repository
2. Install dependencies with `npm install`
3. Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
4. Enable Authentication with Google provider
5. Enable Firestore Database
6. Enable Storage
7. Copy your Firebase configuration into `src/services/firebase.ts`
8. Run the app with `npm start`

## Project Structure

```
src/
├── components/
│   ├── auth/
│   ├── chat/
